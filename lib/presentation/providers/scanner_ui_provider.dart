import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'scanner_ui_provider.g.dart';

@riverpod
class ScannerUiNotifier extends _$ScannerUiNotifier {
  @override
  bool build() => false;

  void setProcessing(bool value) {
    state = value;
  }
}
