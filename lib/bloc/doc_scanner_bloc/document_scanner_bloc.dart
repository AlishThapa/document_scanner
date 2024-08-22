import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';

part 'document_scanner_event.dart';

part 'document_scanner_state.dart';

class DocumentScannerBloc extends Bloc<DocumentScannerEvent, DocumentScannerState> {
  final ImagePicker imagePicker;
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  int _selectedCameraIndex = 0;

  DocumentScannerBloc({required this.imagePicker}) : super(DocumentScannerInitial()) {
    on<DocumentScannerEvent>((event, emit) async {
      switch (event.runtimeType) {
        case const (CaptureImageEvent):
          await _captureImage(emit);
          break;
        case const (SwitchCameraEvent):
          await _switchCamera(emit);
          break;
        case const (RemoveImageEvent):
          _removeImage(emit);
          break;
        case const (PickImageFromGalleryEvent):
          await _pickImageFromGallery(emit);
          break;
        default:
          break;
      }
    });

    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _selectedCameraIndex = 0; // Default to the first camera
    _startCamera(_cameras![_selectedCameraIndex]);
  }

  void _startCamera(CameraDescription cameraDescription) async {
    _cameraController = CameraController(cameraDescription, ResolutionPreset.high);
    await _cameraController?.initialize();
    emit(DocumentScannerLoaded(cameraController: _cameraController!));
  }

  Future<void> _switchCamera(Emitter<DocumentScannerState> emit) async {
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras!.length;
    _startCamera(_cameras![_selectedCameraIndex]);
  }

  Future<void> _captureImage(Emitter<DocumentScannerState> emit) async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      final XFile imageFile = await _cameraController!.takePicture();
      emit(DocumentScannerLoaded(
        cameraController: _cameraController!,
        capturedImage: File(imageFile.path),
        isImageDisplayed: true,
      ));
    }
  }

  void _removeImage(Emitter<DocumentScannerState> emit) {
    emit(DocumentScannerLoaded(
      cameraController: _cameraController!,
      isImageDisplayed: false,
    ));
  }

  Future<void> _pickImageFromGallery(Emitter<DocumentScannerState> emit) async {
    XFile? xfile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (xfile != null) {
      emit(DocumentScannerLoaded(
        cameraController: _cameraController!,
        capturedImage: File(xfile.path),
        isImageDisplayed: true,
      ));
    }
  }

  @override
  Future<void> close() {
    _cameraController?.dispose();
    return super.close();
  }
}
