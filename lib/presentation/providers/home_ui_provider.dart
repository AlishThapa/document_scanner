import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_ui_provider.freezed.dart';
part 'home_ui_provider.g.dart';

@freezed
class HomeUiState with _$HomeUiState {
  const factory HomeUiState({
    @Default(false) bool isSelectionMode,
    @Default({}) Set<String> selectedIds,
  }) = _HomeUiState;
}

@riverpod
class HomeUiNotifier extends _$HomeUiNotifier {
  @override
  HomeUiState build() => const HomeUiState();

  void toggleSelectionMode() {
    state = state.copyWith(
      isSelectionMode: !state.isSelectionMode,
      selectedIds: {},
    );
  }

  void toggleSelection(String id) {
    final newSelectedIds = Set<String>.from(state.selectedIds);
    if (newSelectedIds.contains(id)) {
      newSelectedIds.remove(id);
    } else {
      newSelectedIds.add(id);
    }
    state = state.copyWith(selectedIds: newSelectedIds);
  }

  void clearSelection() {
    state = state.copyWith(
      isSelectionMode: false,
      selectedIds: {},
    );
  }
}
