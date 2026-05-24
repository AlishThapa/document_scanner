import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/router/app_router.dart';
import '../../shared/widgets/animated_gradient_bg.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/glass_container.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../providers/history_provider.dart';
import '../../providers/ocr_provider.dart';

class ResultScreen extends ConsumerWidget {
  final String scanId;
  final bool isFromScanner;
  
  const ResultScreen({
    super.key, 
    required this.scanId, 
    this.isFromScanner = false,
  });

  Future<void> _copyToClipboard(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _reanalyze(WidgetRef ref, String imagePath) async {
    HapticFeedback.mediumImpact();
    
    final result = await ref.read(ocrNotifierProvider.notifier).scan(
      imagePath, 
      existingId: scanId,
    );
    
    if (result != null) {
      ref.read(appRouterProvider).pushReplacement(
        '/result/${result.id}${isFromScanner ? '?fromScanner=true' : ''}',
      );
    } else {
      final ocrState = ref.read(ocrNotifierProvider);
      final context = ref.read(appRouterProvider).configuration.navigatorKey.currentContext;
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ocrState.errorMessage ?? 'Re-analysis failed')),
        );
      }
    }
  }

  void _showFullScreenImage(BuildContext context, String imagePath, String heroTag) {
    showDialog(
      context: context,
      useSafeArea: false,
      builder: (context) => Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Center(
              child: Hero(
                tag: heroTag,
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.file(
                    File(imagePath),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyNotifierProvider);
    final isProcessing = ref.watch(ocrNotifierProvider.select((s) => s.status == OcrStatus.processing));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Scan Result', style: AppTypography.title3.copyWith(color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).canPop() 
            ? Navigator.of(context).pop() 
            : ref.read(appRouterProvider).go('/'),
        ),
      ),
      body: AnimatedGradientBg(
        child: SafeArea(
          bottom: false,
          child: historyAsync.when(
            data: (history) {
              final scan = history.firstWhere(
                (s) => s.id == scanId,
                orElse: () => throw Exception('Scan not found'),
              );

              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.m),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image Preview
                          if (scan.imagePath.isNotEmpty)
                            GestureDetector(
                              onTap: () => _showFullScreenImage(context, scan.imagePath, scan.id),
                              child: Hero(
                                tag: scan.id,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Image.file(
                                    File(scan.imagePath),
                                    width: double.infinity,
                                    height: 320,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(height: AppSpacing.l),
                          
                          // Result Card
                          GlassCard(
                            padding: const EdgeInsets.all(AppSpacing.m),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Extracted Text',
                                      style: AppTypography.headline.copyWith(color: AppColors.textPrimary),
                                    ),
                                    IconButton(
                                      onPressed: () => _copyToClipboard(context, scan.text),
                                      icon: const Icon(Icons.copy_rounded, color: AppColors.accentBlue, size: 20),
                                      tooltip: 'Copy text',
                                    ),
                                  ],
                                ),
                                const Divider(color: AppColors.glassBorder, height: 16),
                                const SizedBox(height: AppSpacing.s),
                                SelectableText(
                                  scan.text,
                                  style: AppTypography.body.copyWith(
                                    color: AppColors.textPrimary,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.m),
                                Row(
                                  children: [
                                    Icon(Icons.auto_awesome, color: AppColors.accentBlue.withOpacity(0.7), size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${(scan.confidence * 100).toInt()}% Confidence',
                                      style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxl), // Space for bottom bar
                        ],
                      ),
                    ),
                  ),
                  
                  // Bottom Action Bar
                  GlassContainer(
                    borderRadius: 0,
                    padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.m, AppSpacing.l, AppSpacing.xl),
                    child: Row(
                      children: [
                        if (isFromScanner) ...[
                          Expanded(
                            child: _ActionButton(
                              label: 'Retake',
                              icon: Icons.refresh_rounded,
                              onPressed: () => ref.read(appRouterProvider).push('/scanner'),
                              isSecondary: true,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.m),
                        ],
                        Expanded(
                          child: _ActionButton(
                            label: isProcessing ? 'Analyzing...' : 'Re-analyze',
                            icon: Icons.analytics_outlined,
                            onPressed: isProcessing ? null : () => _reanalyze(ref, scan.imagePath),
                            isLoading: isProcessing,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accentBlue)),
            error: (err, stack) => Center(
              child: Text('Error: $err', style: const TextStyle(color: Colors.white)),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isSecondary;
  final bool isLoading;

  const _ActionButton({
    required this.label,
    required this.icon,
    this.onPressed,
    this.isSecondary = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSecondary ? AppColors.glassMid : AppColors.accentBlue,
          borderRadius: BorderRadius.circular(16),
          border: isSecondary ? Border.all(color: AppColors.glassBorder) : null,
          boxShadow: isSecondary ? null : [
            BoxShadow(
              color: AppColors.accentBlue.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            else ...[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTypography.headline.copyWith(color: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
