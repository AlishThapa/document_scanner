import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../data/models/scan_result.dart';
import '../../../providers/ocr_provider.dart';
import '../../../shared/router/app_router.dart';
import '../../../shared/widgets/glass_container.dart';

class ScanFab extends ConsumerWidget {
  const ScanFab({super.key});

  void _showPickSourceSheet(BuildContext context, WidgetRef ref) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      isScrollControlled: true,
      builder: (sheetContext) => GlassContainer(
        borderRadius: 32,
        padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.xl, AppSpacing.l, AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            Text(
              'Capture Document',
              style: AppTypography.title2.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _SourceButton(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(sheetContext).pop();
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (context.mounted) {
                        context.push('/scanner');
                      }
                    });
                  },
                ),
                _SourceButton(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  onTap: () async {
                    HapticFeedback.lightImpact();
                    Navigator.of(sheetContext).pop();
                    
                    // Small delay to let the sheet pop animation finish
                    await Future.delayed(const Duration(milliseconds: 200));
                    
                    if (context.mounted) {
                      _showInAppGalleryPicker(context, ref);
                    }
                  },
                ),
                  // onTap: () async {
                  //   Navigator.of(sheetContext).pop(); // ← pop FIRST
                  //
                  //   HapticFeedback.lightImpact();
                  //   final ImagePicker picker = ImagePicker();
                  //   try {
                  //     final List<XFile> images = await picker.pickMultiImage(
                  //       imageQuality: 80,
                  //       maxWidth: 1200,
                  //     );
                  //     if (images.isNotEmpty && context.mounted) {
                  //       // Handle selected images
                  //     }
                  //   } catch (e) {
                  //     if (context.mounted) {
                  //       ScaffoldMessenger.of(context).showSnackBar(
                  //         SnackBar(content: Text('Error picking images: $e')),
                  //       );
                  //     }
                  //   }
                  //   // Navigator.of(sheetContext).pop();
                  //
                  //   // await Future.delayed(const Duration(milliseconds: 100));
                  //   //
                  //   // if (!context.mounted) return;
                  //   //
                  //   // // Show loading dialog
                  //   // _showLoadingDialog(context);
                  //   //
                  //   // // Pick and scan multiple images
                  //   // final results = await ref.read(ocrNotifierProvider.notifier).pickAndScanMultipleImages();
                  //   //
                  //   // // Close loading dialog
                  //   // if (context.mounted) {
                  //   //   Navigator.of(context).pop(); // Close loading dialog
                  //   //
                  //   //   if (results.isNotEmpty && results.any((r) => r != null)) {
                  //   //     // Show success message or navigate to results
                  //   //     _showResultsDialog(context, results.whereType<ScanResult>().toList());
                  //   //   } else if (results.isEmpty || results.every((r) => r == null)) {
                  //   //     _showErrorSnackBar(context, 'No documents were successfully scanned');
                  //   //   }
                  //   // }
                  // },

              ],
            ),
          ],
        ),
      ),
    );
  }

  // Add this method to ScanFab:
  Future<void> _showInAppGalleryPicker(BuildContext context, WidgetRef ref) async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (!ps.hasAccess && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo access denied')),
      );
      return;
    }

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (_) => _InAppGalleryPicker(
        onConfirm: (assets) async {
          if (!context.mounted) return;
          
          _showLoadingDialog(context);

          try {
            final xFiles = <XFile>[];
            for (final a in assets) {
              final file = await a.file;
              if (file != null) {
                xFiles.add(XFile(file.path));
              }
            }

            if (!context.mounted) return;

            if (xFiles.isEmpty) {
              if (Navigator.of(context, rootNavigator: true).canPop()) {
                Navigator.of(context, rootNavigator: true).pop();
              }
              _showErrorSnackBar(context, 'Could not load selected images');
              return;
            }

            final results = await ref.read(ocrNotifierProvider.notifier).scanMultipleImages(xFiles);

            if (context.mounted) {
              if (Navigator.of(context, rootNavigator: true).canPop()) {
                Navigator.of(context, rootNavigator: true).pop(); 
              }

              final validResults = results.whereType<ScanResult>().toList();

              if (validResults.isNotEmpty) {
                if (validResults.length == 1) {
                  context.push('/result/${validResults.first.id}');
                } else {
                  _showResultsDialog(context, validResults);
                }
              } else {
                _showErrorSnackBar(context, 'No documents were successfully scanned');
              }
            }
          } catch (e) {
            if (context.mounted) {
              if (Navigator.of(context, rootNavigator: true).canPop()) {
                Navigator.of(context, rootNavigator: true).pop();
              }
              _showErrorSnackBar(context, 'Error: $e');
            }
          }
        },
      ),
    );
  }
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final ocrState = ref.watch(ocrNotifierProvider);
          return Center(
            child: GlassContainer(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: AppColors.accentBlue),
                  const SizedBox(height: AppSpacing.m),
                  Text(
                    'Analyzing Documents...',
                    style: AppTypography.headline.copyWith(color: AppColors.textPrimary),
                  ),
                  if (ocrState.progress > 0) ...[
                    const SizedBox(height: AppSpacing.m),
                    Text(
                      '${(ocrState.progress * 100).toInt()}%',
                      style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.s),
                    LinearProgressIndicator(
                      value: ocrState.progress,
                      backgroundColor: AppColors.glassMid,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentBlue),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showResultsDialog(BuildContext context, List<ScanResult> results) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Successfully Scanned ${results.length} Document${results.length > 1 ? 's' : ''}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var result in results.take(3)) // Show first 3 results
              ListTile(
                leading: const Icon(Icons.description, color: AppColors.accentBlue),
                title: Text(result.text ?? 'Untitled'),
                subtitle: Text(result.text.substring(0, min(50, result.text.length))),
              ),
            if (results.length > 3) Text('And ${results.length - 3} more...'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to history or results page
              context.push('/history');
            },
            child: const Text('View History'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showPickSourceSheet(context, ref),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.accentBlue.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.4, 1.4),
                duration: 2000.ms,
                curve: Curves.easeInOut,
              )
              .fadeOut(duration: 2000.ms),
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.accentBlue, AppColors.accentPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.camera_alt_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.glassMid,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.glassBorder, width: 0.5),
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            label,
            style: AppTypography.subheadline.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack);
  }
}
// Add this widget at the bottom of the file:
class _InAppGalleryPicker extends StatefulWidget {
  final void Function(List<AssetEntity> assets) onConfirm;
  const _InAppGalleryPicker({required this.onConfirm});

  @override
  State<_InAppGalleryPicker> createState() => _InAppGalleryPickerState();
}

class _InAppGalleryPickerState extends State<_InAppGalleryPicker> {
  List<AssetEntity> _assets = [];
  final List<AssetEntity> _selected = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    final albums = await PhotoManager.getAssetPathList(type: RequestType.image);
    if (albums.isEmpty) { setState(() => _loading = false); return; }
    final assets = await albums.first.getAssetListPaged(page: 0, size: 80);
    setState(() { _assets = assets; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 32,
      padding: const EdgeInsets.fromLTRB(0, AppSpacing.m, 0, AppSpacing.xxl),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            // Handle
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.m),
              decoration: BoxDecoration(
                color: AppColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Select Photos', style: AppTypography.title2.copyWith(color: AppColors.textPrimary)),
                  if (_selected.isNotEmpty)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onConfirm(_selected);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: Text(
                        'Add (${_selected.length})',
                        style: AppTypography.subheadline.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.accentBlue))
                  : GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
                itemCount: _assets.length,
                itemBuilder: (_, i) {
                  final asset = _assets[i];
                  final isSelected = _selected.contains(asset);
                  final selIdx = _selected.indexOf(asset);
                  return GestureDetector(
                    onTap: () => setState(() {
                      isSelected ? _selected.remove(asset) : _selected.add(asset);
                    }),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        AssetEntityImage(asset, isOriginal: false, fit: BoxFit.cover),
                        if (isSelected)
                          Container(color: AppColors.accentBlue.withValues(alpha: 0.35)),
                        Positioned(
                          top: 6, right: 6,
                          child: Container(
                            width: 24, height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected ? AppColors.accentBlue : Colors.black38,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                            child: isSelected
                                ? Center(
                              child: Text(
                                '${selIdx + 1}',
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            )
                                : null,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}