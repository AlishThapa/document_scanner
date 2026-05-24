import '../models/scan_result.dart';
import '../datasources/mlkit_datasource.dart';
import 'ocr_repository.dart';

class OcrRepositoryImpl implements OcrRepository {
  final OcrRepository _delegate;

  OcrRepositoryImpl()
      : _delegate = MlKitDataSource(); // Using ML Kit for both platforms for stability

  @override
  Future<ScanResult> recognizeText(String imagePath) =>
      _delegate.recognizeText(imagePath);
}
