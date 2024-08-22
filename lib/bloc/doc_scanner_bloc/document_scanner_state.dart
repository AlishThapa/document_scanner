part of 'document_scanner_bloc.dart';

@immutable

sealed class DocumentScannerState {}

final class DocumentScannerInitial extends DocumentScannerState {}

final class DocumentScannerLoading extends DocumentScannerState {}

final class DocumentScannerLoaded extends DocumentScannerState {
  final CameraController cameraController;
  final File? capturedImage;
  final bool isImageDisplayed;

  DocumentScannerLoaded({
    required this.cameraController,
    this.capturedImage,
    this.isImageDisplayed = false,
  });
}

final class DocumentScannerError extends DocumentScannerState {
  final String message;

  DocumentScannerError({required this.message});
}