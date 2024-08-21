// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image/image.dart' as img;
//
// class PhotoEditPage extends StatefulWidget {
//   final File image;
//
//   const PhotoEditPage({Key? key, required this.image}) : super(key: key);
//
//   @override
//   _PhotoEditPageState createState() => _PhotoEditPageState();
// }
//
// class _PhotoEditPageState extends State<PhotoEditPage> {
//   late img.Image _image;
//   double _brightness = 0.0;
//   double _contrast = 1.0;
//   double _saturation = 1.0;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadImage();
//   }
//
//   void _loadImage() async {
//     final imageBytes = await widget.image.readAsBytes();
//     setState(() {
//       _image = img.decodeImage(Uint8List.fromList(imageBytes))!;
//     });
//   }
//
//   void _applyEdits() {
//     img.Image editedImage = img.copyResize(_image, width: _image.width, height: _image.height);
//
//     // Apply brightness
//     img.adjustColor(editedImage, brightness: _brightness);
//
//     // Apply contrast
//     img.adjustColor(editedImage, contrast: _contrast);
//
//     // Apply saturation
//     img.adjustColor(editedImage, saturation: _saturation);
//
//     setState(() {
//       _image = editedImage;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Edit Image'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: Center(
//               child: _image == null
//                   ? CircularProgressIndicator()
//                   : Image.memory(Uint8List.fromList(img.encodeJpg(_image))),
//             ),
//           ),
//           Slider(
//             value: _brightness,
//             min: -1.0,
//             max: 1.0,
//             label: 'Brightness',
//             onChanged: (value) {
//               setState(() {
//                 _brightness = value;
//               });
//               _applyEdits();
//             },
//           ),
//           Slider(
//             value: _contrast,
//             min: 0.0,
//             max: 2.0,
//             label: 'Contrast',
//             onChanged: (value) {
//               setState(() {
//                 _contrast = value;
//               });
//               _applyEdits();
//             },
//           ),
//           Slider(
//             value: _saturation,
//             min: 0.0,
//             max: 2.0,
//             label: 'Saturation',
//             onChanged: (value) {
//               setState(() {
//                 _saturation = value;
//               });
//               _applyEdits();
//             },
//           ),
//           // Add more sliders or controls for additional editing options
//         ],
//       ),
//     );
//   }
// }
