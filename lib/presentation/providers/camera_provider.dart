import 'package:camera/camera.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'camera_provider.g.dart';

@riverpod
class CameraNotifier extends _$CameraNotifier {
  CameraController? _controller;

  @override
  AsyncValue<CameraController?> build() {
    ref.onDispose(() {
      _controller?.dispose();
    });
    return const AsyncValue.data(null);
  }

  Future<void> initialize() async {
    state = const AsyncValue.loading();
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception('No cameras available');
      }

      _controller = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      state = AsyncValue.data(_controller);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<XFile?> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return null;
    }
    return await _controller!.takePicture();
  }
}
