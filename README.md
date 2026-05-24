# 🌟 LuminaScan

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Riverpod](https://img.shields.io/badge/State-Riverpod-blue?style=for-the-badge)](https://riverpod.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Clean-green?style=for-the-badge)](#-architecture)

**LuminaScan** is a premium, high-performance OCR (Optical Character Recognition) application built with Flutter. It combines cutting-edge machine learning with a sophisticated iOS 17+ inspired design system to provide a seamless document scanning experience.

---

## ✨ Key Features

- **🚀 Ultra-Fast OCR**: Real-time text extraction using Google ML Kit (Android) and Tesseract/Apple Vision (iOS).
- **🖼️ Multi-Source Capture**: Capture documents directly via the camera or select multiple images from a custom in-app gallery.
- **💎 Premium UI/UX**: 
  - **Glassmorphism**: Beautiful frosted glass surfaces and translucent layers.
  - **Fluid Animations**: 400ms spring-based transitions and entrance animations using `flutter_animate`.
  - **Haptics**: Tactile feedback on every significant interaction.
- **📂 Smart History**: Persistent storage for all your scans with search and bulk-deletion capabilities.
- **📄 Result Management**: Copy, share, or re-analyze extracted text with a single tap.
- **🧩 Batch Processing**: Scan multiple documents in sequence with a real-time progress indicator.

---

## 🎨 Design Philosophy

LuminaScan is built on a custom design system that prioritizes depth, clarity, and motion:

- **Backgrounds**: Slow-moving animated mesh gradients that give the app a living feel.
- **Typography**: Optimized for SF Pro Display to ensure high readability and native feel.
- **Components**: Custom `GlassContainer` and `GlassCard` widgets provide consistent translucency throughout the app.

---

## 🛠️ Tech Stack

- **Core**: [Flutter](https://flutter.dev) (Dart)
- **State Management**: [Riverpod 2.0](https://riverpod.dev) with Code Generation
- **Navigation**: [GoRouter](https://pub.dev/packages/go_router) for declarative routing
- **OCR Engines**:  `google_mlkit_text_recognition`
- **Animations**: `flutter_animate` & `Lottie`
- **Storage**: `SharedPreferences` & `Path Provider`
- **Image Handling**: `ImagePicker`, `PhotoManager`, and `Image` package for preprocessing

---

## 🏗️ Architecture

The project follows a robust **Clean Architecture** pattern, ensuring separation of concerns and testability:

- **Presentation**: Riverpod Notifiers and modern Consumer widgets.
- **Domain**: Use cases and abstract repository interfaces.
- **Data**: Repository implementations, Platform DataSources (ML Kit/Tesseract), and Freezed data models.

---

## 📂 Project Structure

```bash
lib/
├── core/           # Constants, Typography, Theme, Utils
├── data/           # Models, Repositories, DataSources
├── domain/         # Use Cases & Interfaces
├── presentation/   # Screens, Providers, Shared Widgets, Router
└── main.dart       # Entry Point
```

---

## 🚀 Getting Started

1. **Clone the repo**:
   ```bash
   git clone https://github.com/AlishThapa/document_scanner.git
   ```
2. **Install dependencies**:
   ```bash
   flutter pub get
   ```
3. **Run build runner** (for code generation):
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
4. **Launch the app**:
   ```bash
   flutter run
   ```

---

## 📱 Screenshots

| Home | Camera Options | Result |
<img width="1290" height="2796" alt="Image" src="https://github.com/user-attachments/assets/b320216c-d3d0-4ad2-96c1-86122a3ab310" />
| :---: | :---: | :---: | :---: |
| ![Home](<img width="1290" height="2796" alt="Image" src="https://github.com/user-attachments/assets/b320216c-d3d0-4ad2-96c1-86122a3ab310" />) | ![Camera Options](<img width="1290" height="2796" alt="Image" src="https://github.com/user-attachments/assets/56473887-7a52-41e1-acce-4ff57faf15b2" />) | ![Result](<img width="1290" height="2796" alt="Image" src="https://github.com/user-attachments/assets/1ff0f922-e804-4fca-846b-a9d45185c4fa" />) |

---

*Built with ❤️ by the Alish Thapa.*
