// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ocr_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$ocrRepositoryHash() => r'f1858bbd955df15a2e0954f3c6af7d0d79fb5815';

/// See also [ocrRepository].
@ProviderFor(ocrRepository)
final ocrRepositoryProvider = AutoDisposeProvider<OcrRepository>.internal(
  ocrRepository,
  name: r'ocrRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$ocrRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OcrRepositoryRef = AutoDisposeProviderRef<OcrRepository>;
String _$ocrNotifierHash() => r'5e041e5e0d1fec59cf6792492486aa01e8fa41af';

/// See also [OcrNotifier].
@ProviderFor(OcrNotifier)
final ocrNotifierProvider =
    AutoDisposeNotifierProvider<OcrNotifier, OcrState>.internal(
  OcrNotifier.new,
  name: r'ocrNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$ocrNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$OcrNotifier = AutoDisposeNotifier<OcrState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
