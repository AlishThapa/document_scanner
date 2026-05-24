// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ScanResultImpl _$$ScanResultImplFromJson(Map<String, dynamic> json) =>
    _$ScanResultImpl(
      id: json['id'] as String,
      text: json['text'] as String,
      imagePath: json['imagePath'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      engine: json['engine'] as String? ?? 'unknown',
      language: json['language'] as String?,
    );

Map<String, dynamic> _$$ScanResultImplToJson(_$ScanResultImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'imagePath': instance.imagePath,
      'timestamp': instance.timestamp.toIso8601String(),
      'confidence': instance.confidence,
      'engine': instance.engine,
      'language': instance.language,
    };
