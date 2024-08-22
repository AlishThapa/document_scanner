import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:meta/meta.dart';

part 'recognizer_event.dart';

part 'recognizer_state.dart';

class RecognizerBloc extends Bloc<RecognizerEvent, RecognizerState> {
  late TextRecognizer _recognizer;

  RecognizerBloc() : super(RecognizerInitial()) {
    on<CopyToClipboard>(_copyToClipboard);
    on<PerformTextRecognition>(_performTextRecognition);
    _initializeRecognizer();
  }

  void _initializeRecognizer() {
    _recognizer = TextRecognizer(script: TextRecognitionScript.latin);
  }

  Future<void> _performTextRecognition(PerformTextRecognition event, Emitter<RecognizerState> emit) async {
    emit(RecognizerLoading());
    try {
      final inputImage = InputImage.fromFile(event.image);
      final RecognizedText recognizedText = await _recognizer.processImage(inputImage);
      emit(RecognizerSuccess(recognizedText: recognizedText.text));
    } catch (e) {
      emit(RecognizerError(error: e.toString()));
    }
  }

  Future<void> _copyToClipboard(CopyToClipboard event, Emitter<RecognizerState> emit) async {
    if (state is RecognizerSuccess) {
      final text = (state as RecognizerSuccess).recognizedText;
      Clipboard.setData(ClipboardData(text: text));
      // You can use emit to update state if necessary.
    }
  }
}
