import 'package:freezed_annotation/freezed_annotation.dart';

part 'scan_result.freezed.dart';
part 'scan_result.g.dart';

@freezed
class ScanResult with _$ScanResult {
  const factory ScanResult({
    required String id,            // UUID v4
    required String text,          // Extracted text
    required String imagePath,     // Absolute path to saved image
    required DateTime timestamp,
    @Default(0.0) double confidence, // 0–1, ML Kit provides this; Tesseract defaults to 0.9
    @Default('unknown') String engine, // 'mlkit' | 'tesseract'
    String? language,
  }) = _ScanResult;

  factory ScanResult.fromJson(Map<String, dynamic> json) =>
      _$ScanResultFromJson(json);
}
