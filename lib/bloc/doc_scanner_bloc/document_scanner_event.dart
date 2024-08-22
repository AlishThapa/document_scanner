part of 'document_scanner_bloc.dart';

@immutable
sealed class DocumentScannerEvent {}

final class CaptureImageEvent extends DocumentScannerEvent {}

final class SwitchCameraEvent extends DocumentScannerEvent {}

final class RemoveImageEvent extends DocumentScannerEvent {}

final class PickImageFromGalleryEvent extends DocumentScannerEvent {}
