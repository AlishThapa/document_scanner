# AGENTS.md — Flutter OCR Application

> **Spec for AI coding agents** (Claude Code, Cursor, Copilot, etc.)  
> Read this file **in full** before writing or modifying any code.

---

## 1. Project Overview

A cross-platform Flutter OCR (Optical Character Recognition) application that:

- Uses **Google ML Kit** (`google_mlkit_text_recognition`) on **Android**
- Uses **Tesseract OCR** (`tesseract_ocr: ^0.5.0`, backed by Apple Vision) on **iOS**
- Manages all state with **Riverpod** (`flutter_riverpod` + `riverpod_annotation`)
- Delivers a **premium iOS-style UI** — frosted glass, SF-inspired typography, fluid animations, and seamless UX

The app lets users capture or pick an image, runs OCR, displays the extracted text with copy/share actions, and maintains a history of past scans.

---

## 2. Tech Stack & Package Versions

```yaml
# pubspec.yaml — authoritative dependency list

dependencies:
  flutter:
    sdk: flutter

  # State management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # OCR — platform-split (see §4)
  google_mlkit_text_recognition: ^0.13.1   # Android only
  tesseract_ocr: ^0.5.0                    # iOS only

  # Camera / image picking
  image_picker: ^1.1.2
  camera: ^0.11.0

  # Image processing
  image: ^4.2.0

  # Storage & persistence
  shared_preferences: ^2.3.2
  path_provider: ^2.1.4

  # UI utilities
  flutter_animate: ^4.5.0
  blur: ^3.1.0
  share_plus: ^10.0.2
  flutter_svg: ^2.0.10+1
  lottie: ^3.1.2

  # Utils
  uuid: ^4.4.2
  intl: ^0.19.0
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.11
  riverpod_generator: ^2.4.3
  freezed: ^2.5.7
  json_serializable: ^6.8.0
  flutter_lints: ^4.0.0
```

> **Never** add packages not listed here without updating this file first and noting the reason.

---

## 3. Project Structure

```
lib/
├── main.dart                        # App entry point, ProviderScope
├── app.dart                         # MaterialApp / CupertinoApp setup
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart          # Glassmorphism palette, frosted tones
│   │   ├── app_typography.dart      # SF Pro–inspired text styles
│   │   ├── app_spacing.dart         # 4-pt grid constants
│   │   └── app_durations.dart       # Animation duration constants
│   ├── extensions/
│   │   ├── context_ext.dart         # MediaQuery, Theme helpers
│   │   └── string_ext.dart          # Text utilities
│   ├── utils/
│   │   ├── haptics.dart             # HapticFeedback wrappers
│   │   └── logger.dart              # Structured logging
│   └── errors/
│       └── app_exception.dart       # Sealed error types
│
├── data/
│   ├── models/
│   │   ├── scan_result.dart         # Freezed model: id, text, imagePath, timestamp, confidence
│   │   └── scan_result.g.dart       # Generated
│   ├── repositories/
│   │   ├── ocr_repository.dart      # Abstract interface
│   │   ├── ocr_repository_impl.dart # Platform-dispatching impl (see §4)
│   │   └── history_repository.dart  # SharedPreferences persistence
│   └── datasources/
│       ├── mlkit_datasource.dart    # Android: ML Kit calls
│       └── tesseract_datasource.dart# iOS: Tesseract calls
│
├── domain/
│   └── usecases/
│       ├── run_ocr_usecase.dart
│       ├── get_history_usecase.dart
│       └── delete_scan_usecase.dart
│
├── presentation/
│   ├── providers/
│   │   ├── ocr_provider.dart        # @riverpod AsyncNotifier
│   │   ├── history_provider.dart    # @riverpod AsyncNotifier
│   │   ├── camera_provider.dart     # @riverpod StateNotifier
│   │   └── providers.g.dart        # Generated
│   │
│   ├── screens/
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   └── widgets/
│   │   │       ├── scan_fab.dart
│   │   │       ├── recent_scans_list.dart
│   │   │       └── glass_app_bar.dart
│   │   ├── scanner/
│   │   │   ├── scanner_screen.dart
│   │   │   └── widgets/
│   │   │       ├── camera_preview_card.dart
│   │   │       ├── scan_overlay.dart        # Animated corner guides
│   │   │       └── shutter_button.dart
│   │   ├── result/
│   │   │   ├── result_screen.dart
│   │   │   └── widgets/
│   │   │       ├── text_result_card.dart
│   │   │       ├── confidence_badge.dart
│   │   │       └── action_bar.dart          # Copy, Share, Save
│   │   └── history/
│   │       ├── history_screen.dart
│   │       └── widgets/
│   │           ├── history_tile.dart
│   │           └── empty_history.dart
│   │
│   └── shared/
│       ├── widgets/
│       │   ├── glass_container.dart         # Core glassmorphism widget
│       │   ├── glass_card.dart
│       │   ├── frosted_nav_bar.dart
│       │   ├── loading_shimmer.dart
│       │   ├── haptic_button.dart
│       │   └── animated_gradient_bg.dart
│       └── router/
│           └── app_router.dart              # go_router routes
│
└── l10n/                                    # Localization (optional sprint 2)
```

---

## 4. Platform OCR Strategy

### Dispatcher pattern — single interface, two backends

```dart
// lib/data/repositories/ocr_repository.dart
abstract interface class OcrRepository {
  Future<ScanResult> recognizeText(String imagePath);
}

// lib/data/repositories/ocr_repository_impl.dart
class OcrRepositoryImpl implements OcrRepository {
  final OcrRepository _delegate;

  OcrRepositoryImpl()
      : _delegate = Platform.isIOS
            ? TesseractDataSource()
            : MlKitDataSource();

  @override
  Future<ScanResult> recognizeText(String imagePath) =>
      _delegate.recognizeText(imagePath);
}
```

### Android — Google ML Kit

```dart
// lib/data/datasources/mlkit_datasource.dart
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class MlKitDataSource implements OcrRepository {
  final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  @override
  Future<ScanResult> recognizeText(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final recognized = await _recognizer.processImage(inputImage);
    // Map recognized.blocks → ScanResult
  }

  void dispose() => _recognizer.close();
}
```

**Android `build.gradle` requirements:**
```groovy
android {
  defaultConfig {
    minSdk 21        // ML Kit minimum
  }
}
```

### iOS — Tesseract OCR (Apple Vision under the hood)

```dart
// lib/data/datasources/tesseract_datasource.dart
import 'package:tesseract_ocr/tesseract_ocr.dart';

class TesseractDataSource implements OcrRepository {
  @override
  Future<ScanResult> recognizeText(String imagePath) async {
    final text = await TesseractOcr.extractText(imagePath, language: 'eng');
    // Build ScanResult from text
  }
}
```

**iOS `Info.plist` entries required:**
```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is needed to scan documents and text.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Photo library access is needed to pick images for scanning.</string>
```

**iOS `Podfile` minimum deployment:**
```ruby
platform :ios, '14.0'
```

> **Agent rule**: Never import `google_mlkit_text_recognition` in iOS-target files and never import `tesseract_ocr` in Android-target files. Use the dispatcher.

---

## 5. State Management — Riverpod

Use **code generation** (`riverpod_annotation`) exclusively. No manual provider declarations.

### Provider conventions

| Layer | Provider type | Naming pattern |
|---|---|---|
| Repository singletons | `@riverpod` (keepAlive) | `ocrRepository` |
| Use-case singletons | `@riverpod` (keepAlive) | `runOcrUseCase` |
| Screen-level async state | `@riverpod AsyncNotifier` | `ocrNotifier`, `historyNotifier` |
| Ephemeral UI state | `@riverpod Notifier` | `cameraNotifier` |

### OCR provider skeleton

```dart
// lib/presentation/providers/ocr_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/scan_result.dart';

part 'ocr_provider.g.dart';

enum OcrStatus { idle, processing, success, error }

@freezed
class OcrState with _$OcrState {
  const factory OcrState({
    @Default(OcrStatus.idle) OcrStatus status,
    ScanResult? result,
    String? errorMessage,
    @Default(0.0) double progress,   // 0–1 for progress indicator
  }) = _OcrState;
}

@riverpod
class OcrNotifier extends _$OcrNotifier {
  @override
  OcrState build() => const OcrState();

  Future<void> scan(String imagePath) async {
    state = state.copyWith(status: OcrStatus.processing, progress: 0.0);
    try {
      final repo = ref.read(ocrRepositoryProvider);
      final result = await repo.recognizeText(imagePath);
      state = state.copyWith(status: OcrStatus.success, result: result);
      // Persist to history
      await ref.read(historyNotifierProvider.notifier).addScan(result);
    } catch (e) {
      state = state.copyWith(
        status: OcrStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() => state = const OcrState();
}
```

### Rules for agents

- Always run `flutter pub run build_runner build --delete-conflicting-outputs` after modifying annotated providers.
- Never use `ref.read` inside `build()` for subscriptions — use `ref.watch`.
- Use `ref.listen` for side effects (navigation, toasts) in widgets.
- Dispose camera controllers in `ref.onDispose`.

---

## 6. Data Model

```dart
// lib/data/models/scan_result.dart
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
```

---

## 7. UI & Design System

### Philosophy

The app must feel like a **native iOS 17+ app** with subtle material depth:

- **Frosted glass** surfaces everywhere (not flat white/grey cards)
- **SF Pro–inspired** typography — use `cupertino_icons`, set `fontFamily: '.SF Pro Display'` in theme (falls back to system on Android)
- **Blur + translucency** via the `blur` package
- **Spring animations** for transitions and element entrances
- **Haptic feedback** on every significant interaction
- Consistent **4-pt spacing grid**

### Color palette

```dart
// lib/core/constants/app_colors.dart
class AppColors {
  // Backgrounds
  static const bgDark      = Color(0xFF0A0A0F);   // Near-black base
  static const bgMid       = Color(0xFF12121A);
  static const bgSurface   = Color(0xFF1C1C2E);   // Elevated surface

  // Glass layers
  static const glassLight  = Color(0x1AFFFFFF);   // 10% white
  static const glassMid    = Color(0x26FFFFFF);   // 15% white
  static const glassBorder = Color(0x33FFFFFF);   // 20% white border

  // Accent
  static const accentBlue  = Color(0xFF0A84FF);   // iOS system blue
  static const accentTeal  = Color(0xFF32D2C8);
  static const accentPurple= Color(0xFFBF5AF2);

  // Text
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xB3FFFFFF);   // 70% white
  static const textTertiary= Color(0x66FFFFFF);   // 40% white

  // Status
  static const success     = Color(0xFF30D158);
  static const warning     = Color(0xFFFFD60A);
  static const error       = Color(0xFFFF453A);
}
```

### Glass container widget

```dart
// lib/presentation/shared/widgets/glass_container.dart
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blurSigma;
  final Color? tint;
  final EdgeInsetsGeometry? padding;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.blurSigma = 20,
    this.tint,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: tint ?? AppColors.glassLight,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: AppColors.glassBorder, width: 0.5),
          ),
          child: child,
        ),
      ),
    );
  }
}
```

### Animated gradient background

Every screen must sit on top of `AnimatedGradientBg` — a slow-moving mesh gradient that gives depth without distraction.

```dart
// lib/presentation/shared/widgets/animated_gradient_bg.dart
// Use AnimationController (vsync: TickerProviderStateMixin or SingleTickerProviderStateMixin)
// Animate between 3–4 radial gradients using Tween<Alignment>
// Duration: 8 seconds, repeat with reverse
// Opacity: 0.6 — don't overpower content
```

### Typography scale

```dart
// lib/core/constants/app_typography.dart
class AppTypography {
  static const largeTitle  = TextStyle(fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: -0.5);
  static const title1      = TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.3);
  static const title2      = TextStyle(fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: -0.2);
  static const title3      = TextStyle(fontSize: 20, fontWeight: FontWeight.w600);
  static const headline    = TextStyle(fontSize: 17, fontWeight: FontWeight.w600);
  static const body        = TextStyle(fontSize: 17, fontWeight: FontWeight.w400);
  static const callout     = TextStyle(fontSize: 16, fontWeight: FontWeight.w400);
  static const subheadline = TextStyle(fontSize: 15, fontWeight: FontWeight.w400);
  static const footnote    = TextStyle(fontSize: 13, fontWeight: FontWeight.w400);
  static const caption     = TextStyle(fontSize: 12, fontWeight: FontWeight.w400);
}
```

---

## 8. Screen Specifications

### 8.1 Home Screen

**Layout**: Full-screen animated gradient → frosted nav bar → two-column stat cards → recent scans list → floating scan FAB

**Required elements**:
- `GlassAppBar` — title "Scanner", settings icon, history icon — blurs content scrolling behind it
- Stats row: "Scans Today" + "Total Scans" in `GlassCard`s
- `RecentScansList` — last 5 scans, swipe-to-delete with haptic feedback
- `ScanFab` — pulsing ring animation when idle, morphs to X when camera is open

**Interactions**:
- Pull-to-refresh animates with a custom Lottie indicator
- Tapping a recent scan navigates to `ResultScreen` with hero animation on the image

### 8.2 Scanner Screen

**Layout**: Full-screen camera preview → semi-transparent overlay → animated scan guides → bottom action shelf

**Required elements**:
- `CameraPreviewCard` — fills screen, corner-radius 0 (edge-to-edge)
- `ScanOverlay` — four corner L-brackets that animate (pulse + color change) when text is detected
- Bottom glass shelf with:
    - Gallery pick button (left)
    - `ShutterButton` (center) — circular, white border, ripple on tap
    - Flash toggle (right)
- Real-time text detection highlight: draw bounding boxes over detected text blocks using `CustomPainter`

**Interactions**:
- Shutter tap → heavy haptic → freeze frame → processing animation → navigate to result
- Gallery pick → image picker → same processing flow
- Pinch-to-zoom on preview

### 8.3 Result Screen

**Layout**: Hero-expanded image (top 40%) → scrollable text card (bottom 60%) → floating action bar

**Required elements**:
- Image with rounded bottom corners, tap to fullscreen
- `ConfidenceBadge` — pill chip showing engine + confidence %, color-coded (green >80%, yellow 60–80%, red <60%)
- `TextResultCard` — glassmorphism card, monospace-adjacent font for extracted text, line-by-line fade-in animation
- `ActionBar` (fixed bottom, glass) — Copy, Share, Save to Files, Retake
- Word count + character count metadata row

**Interactions**:
- Text is selectable and highlights on long-press
- Copy button triggers success haptic + animated checkmark swap
- Share opens native share sheet

### 8.4 History Screen

**Layout**: Large title header → search bar → grouped list (Today / This Week / Earlier)

**Required elements**:
- `GlassSearchBar` — blurred background, real-time filtering via `historyNotifier`
- `HistoryTile` — thumbnail, first line of text, timestamp, engine badge
- Swipe-to-delete with confirmatory haptic
- `EmptyHistory` — Lottie animation + friendly prompt

---

## 9. Navigation

Use `go_router` (already compatible with Riverpod via `riverpod_annotation`).

```dart
// lib/presentation/shared/router/app_router.dart
@riverpod
GoRouter appRouter(AppRouterRef ref) => GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/',         builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/scanner',  builder: (_, __) => const ScannerScreen()),
    GoRoute(
      path: '/result/:id',
      builder: (_, state) => ResultScreen(scanId: state.pathParameters['id']!),
    ),
    GoRoute(path: '/history',  builder: (_, __) => const HistoryScreen()),
  ],
);
```

Transitions: use `CustomTransitionPage` with a slide-up + fade for modal-style screens (scanner, result) and a standard horizontal slide for history.

---

## 10. Animation Guidelines

| Interaction | Animation | Duration | Curve |
|---|---|---|---|
| Screen enter | Fade + slide up 24px | 380ms | `easeOutCubic` |
| Card appear | Scale 0.95→1.0 + fade | 280ms | `easeOutBack` |
| Button press | Scale 0.96 | 120ms | `easeInOut` |
| FAB pulse | Scale 1.0→1.08→1.0 | 2000ms | `easeInOut`, repeat |
| OCR processing | Shimmer sweep | loop | linear |
| Success state | Scale bounce | 400ms | `elasticOut` |
| Shutter capture | Flash overlay 0→0.6→0 | 250ms | `easeOut` |

Use `flutter_animate` package for all declarative animations. Prefer `.animate().fadeIn().slideY()` chains. Avoid `AnimationController` boilerplate unless custom painting requires it.

---

## 11. Error Handling

```dart
// lib/core/errors/app_exception.dart
sealed class AppException implements Exception {
  const AppException();
}

class CameraPermissionDenied extends AppException {
  const CameraPermissionDenied();
}

class OcrProcessingFailed extends AppException {
  final String message;
  const OcrProcessingFailed(this.message);
}

class NoTextDetected extends AppException {
  const NoTextDetected();
}

class StorageError extends AppException {
  final String message;
  const StorageError(this.message);
}
```

Every error state must render a `GlassCard` with:
- SF Symbols–style icon (use `cupertino_icons`)
- Human-readable message (no raw exception strings)
- Retry action button
- Optional "Report issue" link

---

## 12. Performance Rules

- **Image resizing before OCR**: Resize any image larger than 2048×2048 px using the `image` package before passing to the OCR engine. This prevents OOM on low-RAM devices and speeds up recognition.
- **Isolates**: Run image preprocessing (resize, convert to grayscale) in a `compute()` call — never on the main isolate.
- **Camera disposal**: Always `dispose()` the `CameraController` in `ref.onDispose()`.
- **History pagination**: Load history in pages of 20. Use `ListView.builder` — never `Column` for lists.
- **Avoid rebuilds**: Use `select()` to subscribe to sub-slices of provider state.

```dart
// Good — only rebuilds when status changes
final status = ref.watch(ocrNotifierProvider.select((s) => s.status));

// Bad — rebuilds on every state change
final ocrState = ref.watch(ocrNotifierProvider);
```

---

## 13. Testing

```
test/
├── unit/
│   ├── ocr_repository_test.dart
│   ├── scan_result_test.dart
│   └── history_repository_test.dart
├── widget/
│   ├── glass_container_test.dart
│   ├── result_screen_test.dart
│   └── history_tile_test.dart
└── integration/
    └── scan_flow_test.dart         # Mock OCR engine, full navigation flow
```

- Mock OCR datasources with `mockito` — never call real ML Kit/Tesseract in tests
- Use `ProviderContainer` for unit-testing Riverpod notifiers in isolation
- Aim for >80% coverage on `data/` and `domain/` layers

---

## 14. Agent Task Checklist

When implementing a feature or fixing a bug, the agent must:

- [ ] Re-read §4 before touching any OCR code (platform split is critical)
- [ ] Run `build_runner` after any Riverpod/Freezed/JSON annotation change
- [ ] Verify no ML Kit imports exist in iOS-targeted files and vice versa
- [ ] Ensure every new screen has `AnimatedGradientBg` as the root widget
- [ ] Wrap all new cards/modals in `GlassContainer`
- [ ] Add `HapticFeedback` call to every new button's `onTap`
- [ ] Write at least one unit test for every new repository method
- [ ] Check that `CameraController.dispose()` is called on screen exit
- [ ] Run `flutter analyze` — zero warnings before committing
- [ ] Test on both **Android emulator (API 26+)** and **iOS Simulator (iOS 14+)**

---

## 15. Do Not

- ❌ Do not use `setState` anywhere — all state lives in Riverpod providers
- ❌ Do not use `BuildContext` inside providers or repositories
- ❌ Do not hardcode strings — use constants or l10n keys
- ❌ Do not use `Container` with a solid `color` where `GlassContainer` should be used
- ❌ Do not block the main isolate with image processing
- ❌ Do not import platform-specific OCR packages conditionally at widget layer — use the dispatcher in `data/`
- ❌ Do not use `Navigator.push` directly — always use `context.go()` from `go_router`
- ❌ Do not commit generated `.g.dart` / `.freezed.dart` files with unresolved conflicts

---

*Last updated: May 2026 — bump version and date when this document changes.*