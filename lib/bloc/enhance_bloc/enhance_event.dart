part of 'enhance_bloc.dart';

@immutable
sealed class EnhanceEvent {}

final class SaveImage extends EnhanceEvent {
  final Uint8List imageBytes;
  final BuildContext context;

  SaveImage({required this.imageBytes, required this.context});
}

final class RequestPermissions extends EnhanceEvent {}
