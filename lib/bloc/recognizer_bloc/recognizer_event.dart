part of 'recognizer_bloc.dart';

@immutable
sealed class RecognizerEvent {}

final class CopyToClipboard extends RecognizerEvent {}
class PerformTextRecognition extends RecognizerEvent {
  final File image;

  PerformTextRecognition({required this.image});
}