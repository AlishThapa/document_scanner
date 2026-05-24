import '../models/scan_result.dart';

abstract interface class OcrRepository {
  Future<ScanResult> recognizeText(String imagePath);
}
