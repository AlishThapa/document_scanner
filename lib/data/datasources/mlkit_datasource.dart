import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../models/scan_result.dart';
import '../repositories/ocr_repository.dart';
import 'package:uuid/uuid.dart';

class MlKitDataSource implements OcrRepository {
  final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  @override
  Future<ScanResult> recognizeText(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final recognized = await _recognizer.processImage(inputImage);
    
    return ScanResult(
      id: const Uuid().v4(),
      text: recognized.text,
      imagePath: imagePath,
      timestamp: DateTime.now(),
      confidence: _calculateAverageConfidence(recognized),
      engine: 'mlkit',
    );
  }

  double _calculateAverageConfidence(RecognizedText recognized) {
    if (recognized.blocks.isEmpty) return 0.0;
    // ML Kit doesn't provide a direct confidence for the whole text, 
    // but some implementations might have it per block/line.
    // For this simple impl, we'll return 0.95 if text is found.
    return recognized.text.isNotEmpty ? 0.95 : 0.0;
  }

  void dispose() => _recognizer.close();
}
