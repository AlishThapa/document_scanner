import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/scan_result.dart';
import '../../data/repositories/ocr_repository.dart';
import '../../data/repositories/ocr_repository_impl.dart';
import 'history_provider.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image_picker/image_picker.dart';

part 'ocr_provider.freezed.dart';
part 'ocr_provider.g.dart';

@riverpod
OcrRepository ocrRepository(OcrRepositoryRef ref) {
  return OcrRepositoryImpl();
}

enum OcrStatus { idle, processing, success, error }

@freezed
class OcrState with _$OcrState {
  const factory OcrState({
    @Default(OcrStatus.idle) OcrStatus status,
    ScanResult? result,
    String? errorMessage,
    @Default(0.0) double progress,
  }) = _OcrState;
}

@riverpod
class OcrNotifier extends _$OcrNotifier {
  @override
  OcrState build() => const OcrState();

  Future<ScanResult?> scan(String imagePath, {String? existingId, bool resetProgress = true}) async {
    state = state.copyWith(
      status: OcrStatus.processing,
      progress: resetProgress ? 0.0 : state.progress,
    );
    try {
      final repo = ref.read(ocrRepositoryProvider);
      var result = await repo.recognizeText(imagePath);

      if (existingId != null) {
        result = result.copyWith(id: existingId);
      }

      // Persist to history (handles both add and update)
      await ref.read(historyNotifierProvider.notifier).saveScan(result);

      state = state.copyWith(status: OcrStatus.success, result: result);
      return result;
    } catch (e) {
      state = state.copyWith(
        status: OcrStatus.error,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  /// Picks an image from the gallery and runs OCR on it.
// In your OCR notifier
  Future<XFile?> pickImageOnly() async {
    final picker = ImagePicker();

    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 2048,
        maxHeight: 2048,
      );

      return image;
    } catch (e) {
      state = state.copyWith(
        status: OcrStatus.error,
        errorMessage: 'Failed to pick image: $e',
      );
      return null;
    }
  }

  Future<ScanResult?> scanImage(XFile image) async {
    try {
      return await scan(image.path);
    } catch (e) {
      state = state.copyWith(
        status: OcrStatus.error,
        errorMessage: 'Failed to scan image: $e',
      );
      return null;
    }
  }
  Future<List<XFile>> pickMultipleImages() async {
    final picker = ImagePicker();

    try {
      state = state.copyWith(status: OcrStatus.processing);

      final List<XFile> images = await picker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1200,
      );

      if (images.isEmpty) {
        state = state.copyWith(
          status: OcrStatus.idle,
          errorMessage: 'No images selected',
        );
      }

      return images;
    } catch (e) {
      state = state.copyWith(
        status: OcrStatus.error,
        errorMessage: 'Error picking images: $e',
      );
      return [];
    }
  }

  /// Scan multiple images and return results
  Future<List<ScanResult?>> scanMultipleImages(List<XFile> images) async {
    final results = <ScanResult?>[];

    for (int i = 0; i < images.length; i++) {
      final image = images[i];
      final progress = (i + 1) / images.length;

      state = state.copyWith(
        status: OcrStatus.processing,
        progress: progress,
      );

      try {
        final result = await scan(image.path, resetProgress: false);
        results.add(result);
      } catch (e) {
        results.add(null);
        state = state.copyWith(
          errorMessage: 'Failed to scan image ${i + 1}: $e',
        );
      }
    }

    if (results.isNotEmpty && results.every((r) => r != null)) {
      state = state.copyWith(status: OcrStatus.success);
    } else if (results.isEmpty) {
      state = state.copyWith(
        status: OcrStatus.error,
        errorMessage: 'No images were successfully scanned',
      );
    }

    return results;
  }

  /// Combined method to pick and scan multiple images
  Future<List<ScanResult?>> pickAndScanMultipleImages() async {
    final images = await pickMultipleImages();

    if (images.isEmpty) {
      return [];
    }

    return await scanMultipleImages(images);
  }

  void reset() => state = const OcrState();
}
