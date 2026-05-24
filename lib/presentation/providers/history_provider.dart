import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/scan_result.dart';
import '../../data/repositories/history_repository.dart';

part 'history_provider.g.dart';

@riverpod
HistoryRepository historyRepository(HistoryRepositoryRef ref) {
  return HistoryRepository();
}

@riverpod
class HistoryNotifier extends _$HistoryNotifier {
  @override
  FutureOr<List<ScanResult>> build() async {
    final repo = ref.watch(historyRepositoryProvider);
    return repo.getHistory();
  }

  Future<void> saveScan(ScanResult result) async {
    final currentState = state.valueOrNull;
    if (currentState != null) {
      final index = currentState.indexWhere((s) => s.id == result.id);
      if (index != -1) {
        final newList = List<ScanResult>.from(currentState);
        newList[index] = result;
        state = AsyncData(newList);
      } else {
        state = AsyncData([result, ...currentState]);
      }
    }

    try {
      final repo = ref.read(historyRepositoryProvider);
      await repo.saveScan(result);
    } catch (e, st) {
      ref.invalidateSelf();
      state = AsyncError(e, st);
    }
  }

  Future<void> deleteScan(String id) async {
    final currentState = state.valueOrNull;
    if (currentState != null) {
      state = AsyncData(currentState.where((scan) => scan.id != id).toList());
    }

    try {
      final repo = ref.read(historyRepositoryProvider);
      await repo.deleteScan(id);
    } catch (e, st) {
      // If it fails, we might want to reload to get the real state
      ref.invalidateSelf();
      state = AsyncError(e, st);
    }
  }

  Future<void> deleteMultipleScans(List<String> ids) async {
    final currentState = state.valueOrNull;
    if (currentState != null) {
      state = AsyncData(
        currentState.where((scan) => !ids.contains(scan.id)).toList(),
      );
    }

    try {
      final repo = ref.read(historyRepositoryProvider);
      await repo.deleteMultipleScans(ids);
    } catch (e, st) {
      ref.invalidateSelf();
      state = AsyncError(e, st);
    }
  }

  Future<void> clearHistory() async {
    state = const AsyncData([]);
    try {
      final repo = ref.read(historyRepositoryProvider);
      await repo.clearHistory();
    } catch (e, st) {
      ref.invalidateSelf();
      state = AsyncError(e, st);
    }
  }
}
