import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/animated_gradient_bg.dart';
import '../../shared/widgets/glass_card.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../providers/history_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyNotifierProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Scan History'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AnimatedGradientBg(
        child: SafeArea(
          child: historyAsync.when(
            data: (history) {
              if (history.isEmpty) {
                return const Center(child: Text('No history yet', style: AppTypography.body));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.m),
                itemCount: history.length,
                separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.m),
                itemBuilder: (context, index) {
                  final scan = history[index];
                  final dateStr = DateFormat.yMMMd().add_jm().format(scan.timestamp);
                  
                  return Dismissible(
                    key: Key(scan.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.delete_outline, color: AppColors.error),
                    ),
                    onDismissed: (_) {
                      ref.read(historyNotifierProvider.notifier).deleteScan(scan.id);
                    },
                    child: GestureDetector(
                      onTap: () => context.go('/result/${scan.id}'),
                      child: GlassCard(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: AppColors.glassMid,
                                borderRadius: BorderRadius.circular(12),
                                image: scan.imagePath.isNotEmpty 
                                  ? DecorationImage(
                                      image: FileImage(File(scan.imagePath)),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                              ),
                              child: scan.imagePath.isEmpty 
                                ? const Icon(Icons.description_outlined, color: AppColors.textTertiary)
                                : null,
                            ),
                            const SizedBox(width: AppSpacing.m),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    scan.text.split('\n').firstWhere((s) => s.trim().isNotEmpty, orElse: () => 'No text detected'),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.headline.copyWith(color: AppColors.textPrimary),
                                  ),
                                  Text(
                                    dateStr,
                                    style: AppTypography.footnote.copyWith(color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: AppColors.textTertiary),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ),
      ),
    );
  }
}

