part of 'recognizer_bloc.dart';

@immutable
sealed class RecognizerState {}

final class RecognizerInitial extends RecognizerState {}

final class RecognizerLoading extends RecognizerState {}

class RecognizerSuccess extends RecognizerState {
  final String recognizedText;

  RecognizerSuccess({required this.recognizedText});
}


final class RecognizerError extends RecognizerState {
  final String error;

  RecognizerError({required this.error});
}
