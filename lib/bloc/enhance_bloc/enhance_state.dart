part of 'enhance_bloc.dart';

@immutable
sealed class EnhanceState {}

final class EnhanceInitial extends EnhanceState {}

final class EnhanceLoading extends EnhanceState {}

final class EnhanceSuccess extends EnhanceState {
  final String imagePath;

  EnhanceSuccess({required this.imagePath});
}

final class EnhanceError extends EnhanceState {
  final String error;

  EnhanceError({required this.error});
}
