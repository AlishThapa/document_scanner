import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/scan_result.dart';
import '../../shared/widgets/animated_gradient_bg.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/glass_container.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../providers/history_provider.dart';
import '../../providers/home_ui_provider.dart';
import 'widgets/glass_app_bar.dart';
import 'widgets/scan_fab.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyNotifierProvider);
    final homeUi = ref.watch(homeUiNotifierProvider);
    final homeUiNotifier = ref.read(homeUiNotifierProvider.notifier);

    void toggleSelectionMode() {
      homeUiNotifier.toggleSelectionMode();
      HapticFeedback.mediumImpact();
    }

    void toggleSelection(String id) {
      homeUiNotifier.toggleSelection(id);
      HapticFeedback.lightImpact();
    }

    Future<void> deleteSelected() async {
      if (homeUi.selectedIds.isEmpty) return;

      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.bgSurface,
          title: Text('Delete Scans', style: AppTypography.headline.copyWith(color: AppColors.textPrimary)),
          content: Text('Are you sure you want to delete ${homeUi.selectedIds.length} scans?',
              style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await ref.read(historyNotifierProvider.notifier).deleteMultipleScans(homeUi.selectedIds.toList());
        homeUiNotifier.clearSelection();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Scans deleted')),
          );
        }
      }
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: homeUi.isSelectionMode
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: toggleSelectionMode,
              ),
              title: Text('${homeUi.selectedIds.length} selected',
                  style: AppTypography.headline.copyWith(color: AppColors.textPrimary)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  onPressed: homeUi.selectedIds.isEmpty ? null : deleteSelected,
                ),
              ],
            )
          : const GlassAppBar(title: 'LuminaScan'),
      floatingActionButton: homeUi.isSelectionMode ? null : const ScanFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: AnimatedGradientBg(
        child: SafeArea(
          child: historyAsync.when(
            data: (history) => _HomeContent(
              history: history,
              isSelectionMode: homeUi.isSelectionMode,
              selectedIds: homeUi.selectedIds,
              onToggleSelectionMode: toggleSelectionMode,
              onToggleSelection: toggleSelection,
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final List<ScanResult> history;
  final bool isSelectionMode;
  final Set<String> selectedIds;
  final VoidCallback onToggleSelectionMode;
  final Function(String) onToggleSelection;

  const _HomeContent({
    required this.history,
    required this.isSelectionMode,
    required this.selectedIds,
    required this.onToggleSelectionMode,
    required this.onToggleSelection,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final scansToday = history.where((scan) {
      return scan.timestamp.year == now.year &&
          scan.timestamp.month == now.month &&
          scan.timestamp.day == now.day;
    }).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.s),
          Text(
            'Overview',
            style: AppTypography.title2.copyWith(color: AppColors.textPrimary),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
          const SizedBox(height: AppSpacing.m),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Scans Today',
                  value: scansToday.toString(),
                  icon: Icons.today_rounded,
                  color: AppColors.accentBlue,
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: _StatCard(
                  title: 'Total Scans',
                  value: history.length.toString(),
                  icon: Icons.all_inbox_rounded,
                  color: AppColors.accentTeal,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.95, 0.95)),
          const SizedBox(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Scans',
                style: AppTypography.title2.copyWith(color: AppColors.textPrimary),
              ),
              if (history.length > 5 && !isSelectionMode)
                TextButton(
                  onPressed: () => context.go('/history'),
                  child: Text(
                    'See All',
                    style: AppTypography.subheadline.copyWith(color: AppColors.accentBlue),
                  ),
                ),
            ],
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: AppSpacing.s),
          if (history.isEmpty)
            _EmptyState()
          else
            _RecentScansList(
              history: history.take(5).toList(),
              isSelectionMode: isSelectionMode,
              selectedIds: selectedIds,
              onToggleSelectionMode: onToggleSelectionMode,
              onToggleSelection: onToggleSelection,
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.05),
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.description_outlined, size: 48, color: AppColors.textTertiary),
            const SizedBox(height: AppSpacing.m),
            Text(
              'No scans yet',
              style: AppTypography.headline.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              'Tap the button below to start scanning',
              textAlign: TextAlign.center,
              style: AppTypography.subheadline.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTypography.largeTitle.copyWith(color: AppColors.textPrimary),
          ),
          Text(
            title,
            style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _RecentScansList extends ConsumerWidget {
  final List<ScanResult> history;
  final bool isSelectionMode;
  final Set<String> selectedIds;
  final VoidCallback onToggleSelectionMode;
  final Function(String) onToggleSelection;

  const _RecentScansList({
    required this.history,
    required this.isSelectionMode,
    required this.selectedIds,
    required this.onToggleSelectionMode,
    required this.onToggleSelection,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: history.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.m),
      itemBuilder: (context, index) {
        final scan = history[index];
        final dateStr = DateFormat.yMMMd().add_jm().format(scan.timestamp);
        final isSelected = selectedIds.contains(scan.id);

        return Dismissible(
          key: Key(scan.id),
          direction: isSelectionMode ? DismissDirection.none : DismissDirection.endToStart,
          onDismissed: (_) {
            ref.read(historyNotifierProvider.notifier).deleteScan(scan.id);
            HapticFeedback.mediumImpact();
          },
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.delete_outline, color: AppColors.error),
          ),
          child: GestureDetector(
            onTap: () {
              if (isSelectionMode) {
                onToggleSelection(scan.id);
              } else {
                context.go('/result/${scan.id}');
              }
            },
            onLongPress: () {
              if (!isSelectionMode) {
                onToggleSelectionMode();
                onToggleSelection(scan.id);
              }
            },
            child: GlassCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  if (isSelectionMode) ...[
                    Checkbox(
                      value: isSelected,
                      onChanged: (_) => onToggleSelection(scan.id),
                      activeColor: AppColors.accentBlue,
                      side: const BorderSide(color: AppColors.glassBorder),
                    ),
                    const SizedBox(width: AppSpacing.s),
                  ],
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
                  if (!isSelectionMode)
                    const Icon(Icons.chevron_right, color: AppColors.textTertiary),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
