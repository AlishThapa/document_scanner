import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../providers/camera_provider.dart';
import '../../providers/ocr_provider.dart';
import '../../providers/scanner_ui_provider.dart';
import '../../shared/router/app_router.dart';
import '../../shared/widgets/glass_container.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cameraNotifierProvider.notifier).initialize();
      ref.read(scannerUiNotifierProvider.notifier).setProcessing(false);
    });
  }

  Future<void> _takePicture() async {
    final isProcessing = ref.read(scannerUiNotifierProvider);
    if (isProcessing) return;
    
    HapticFeedback.heavyImpact();
    ref.read(scannerUiNotifierProvider.notifier).setProcessing(true);

    try {
      final file = await ref.read(cameraNotifierProvider.notifier).takePicture();
      if (file != null) {
        if (!mounted) return;
        
        // Show prominent "Analyzing" dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(
            child: GlassContainer(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: AppColors.accentBlue),
                  const SizedBox(height: AppSpacing.m),
                  Text(
                    'Analyzing Text...',
                    style: AppTypography.headline.copyWith(color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
          ),
        );

        final result = await ref.read(ocrNotifierProvider.notifier).scan(file.path);
        
        if (!mounted) return;
        
        // Close analyzing dialog
        Navigator.of(context, rootNavigator: true).pop();
        
        if (result != null) {
          ref.read(appRouterProvider).pushReplacement('/result/${result.id}?fromScanner=true');
        } else {
          final ocrState = ref.read(ocrNotifierProvider);
          ref.read(scannerUiNotifierProvider.notifier).setProcessing(false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(ocrState.errorMessage ?? 'OCR failed')),
          );
        }
      } else {
        ref.read(scannerUiNotifierProvider.notifier).setProcessing(false);
      }
    } catch (e) {
      if (mounted) {
        // Ensure dialog is closed on error
        try {
           Navigator.of(context, rootNavigator: true).pop();
        } catch (_) {}
        ref.read(scannerUiNotifierProvider.notifier).setProcessing(false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cameraState = ref.watch(cameraNotifierProvider);
    final isProcessing = ref.watch(scannerUiNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          cameraState.when(
            data: (controller) {
              if (controller == null || !controller.value.isInitialized) {
                return const Center(child: CircularProgressIndicator());
              }
              return SizedBox.expand(
                child: CameraPreview(controller),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
              child: Text('Error: $err', style: const TextStyle(color: Colors.white)),
            ),
          ),

          // Scan Overlay (Simple guides)
          IgnorePointer(
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.5,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.accentBlue.withOpacity(0.5), width: 2),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),

          // Top Controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: () => ref.read(appRouterProvider).pop(),
              ),
            ),
          ),

          // Bottom Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: GlassContainer(
              borderRadius: 0,
              padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.l, AppSpacing.l, AppSpacing.xxl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const SizedBox(width: 48), // Spacer for symmetry
                  
                  // Shutter Button
                  GestureDetector(
                    onTap: _takePicture,
                    child: Container(
                      width: 80,
                      height: 80,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: isProcessing
                          ? const Center(child: CircularProgressIndicator(color: AppColors.accentBlue))
                          : null,
                      ),
                    ),
                  ),

                  // Gallery Button
                  IconButton(
                    icon: const Icon(Icons.photo_library_rounded, color: Colors.white, size: 32),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      ref.read(appRouterProvider).pop();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
