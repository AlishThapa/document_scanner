// import 'dart:io';
// import 'package:camera/camera.dart';
// import 'package:document_scanner/enhance_page.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:document_scanner/recognizer_page.dart';
//
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key});
//
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   late ImagePicker imagePicker;
//   CameraController? _cameraController;
//   List<CameraDescription>? _cameras;
//   int _selectedCameraIndex = 0;
//   File? _capturedImage; // Holds the captured image
//   bool _isImageDisplayed = false; // Tracks if an image is displayed
//
//   @override
//   void initState() {
//     super.initState();
//     imagePicker = ImagePicker();
//     _initializeCamera();
//   }
//
//   Future<void> _initializeCamera() async {
//     _cameras = await availableCameras();
//     _selectedCameraIndex = 0; // Default to the first camera (usually the back camera)
//     _startCamera(_cameras![_selectedCameraIndex]);
//   }
//
//   void _startCamera(CameraDescription cameraDescription) async {
//     _cameraController = CameraController(cameraDescription, ResolutionPreset.high);
//     await _cameraController?.initialize();
//     setState(() {});
//   }
//
//   void _switchCamera() {
//     _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras!.length;
//     _startCamera(_cameras![_selectedCameraIndex]);
//   }
//
//   void _captureImage() async {
//     if (_cameraController != null && _cameraController!.value.isInitialized) {
//       final XFile imageFile = await _cameraController!.takePicture();
//       setState(() {
//         _capturedImage = File(imageFile.path);
//         _isImageDisplayed = true;
//       });
//     }
//   }
//
//   void _removeImage() {
//     setState(() {
//       _capturedImage = null;
//       _isImageDisplayed = false;
//     });
//   }
//
//   @override
//   void dispose() {
//     _cameraController?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         body: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             _isImageDisplayed
//                 ? Card(
//                     color: Colors.blueAccent,
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 15),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           CustomIconButton(
//                             onTap: () {},
//                             icon: Icons.scanner_outlined,
//                             size: 25,
//                             data: 'Scanner',
//                           ),
//                           CustomIconButton(
//                             onTap: () {
//                               Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => RecognizerPage(image: _capturedImage!),
//                                   ));
//                             },
//                             icon: Icons.document_scanner_outlined,
//                             size: 25,
//                             data: 'Recognize Text',
//                           ),
//                           CustomIconButton(
//                             onTap: () {
//                               Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => EnhanceImagePage(image: _capturedImage!),
//                                   ));
//                             },
//                             icon: Icons.assignment,
//                             size: 25,
//                             data: 'Enhance',
//                           ),
//                         ],
//                       ),
//                     ),
//                   )
//                 : const SizedBox(),
//             SizedBox(height: _isImageDisplayed ? 10 : 0),
//             Expanded(
//               child: Card(
//                 child: _isImageDisplayed
//                     ? Stack(
//                         children: [
//                           Center(
//                             child: Image.file(
//                               _capturedImage!,
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                           Positioned(
//                             top: 10,
//                             right: 10,
//                             child: IconButton(
//                               icon: const Icon(Icons.close, color: Colors.red),
//                               onPressed: _removeImage,
//                             ),
//                           ),
//                         ],
//                       )
//                     : (_cameraController != null && _cameraController!.value.isInitialized)
//                         ? CameraPreview(_cameraController!)
//                         : const Center(child: CircularProgressIndicator()),
//               ),
//             ),
//             const SizedBox(height: 10),
//             Card(
//               color: Colors.blueAccent,
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 25),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     CustomIconButton(
//                       onTap: _switchCamera,
//                       icon: Icons.rotate_left,
//                     ),
//                     CustomIconButton(
//                       onTap: _captureImage,
//                       icon: Icons.camera,
//                       size: 50,
//                     ),
//                     CustomIconButton(
//                       onTap: () async {
//                         XFile? xfile = await imagePicker.pickImage(source: ImageSource.gallery);
//                         if (xfile != null) {
//                           setState(() {
//                             _capturedImage = File(xfile.path);
//                             _isImageDisplayed = true;
//                           });
//                         }
//                       },
//                       icon: Icons.image,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class CustomIconButton extends StatelessWidget {
//   const CustomIconButton({
//     super.key,
//     this.icon,
//     this.size = 35.0,
//     this.data,
//     this.onTap,
//   });
//
//   final IconData? icon;
//   final double size;
//   final String? data;
//   final void Function()? onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       child: Column(
//         children: [
//           Icon(
//             icon,
//             size: size,
//             color: Colors.white,
//           ),
//           data == null
//               ? const SizedBox.shrink()
//               : Text(
//                   data!,
//                   style: const TextStyle(
//                     color: Colors.white,
//                   ),
//                 ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:document_scanner/bloc/doc_scanner_bloc/document_scanner_bloc.dart';
import 'package:document_scanner/screens/enhance_page.dart';
import 'package:document_scanner/screens/recognizer_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';


class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade100,
      body: SafeArea(
        child: BlocBuilder<DocumentScannerBloc, DocumentScannerState>(
          builder: (context, state) {
            if (state is DocumentScannerInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DocumentScannerLoaded) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (state.isImageDisplayed) _buildImageDisplaySection(context, state.capturedImage!),
                  if (state.isImageDisplayed) const SizedBox(height: 10),
                  _buildCameraOrImagePreview(state, context),
                  const SizedBox(height: 10),
                  _buildBottomControls(context),
                ],
              );
            } else if (state is DocumentScannerError) {
              return Center(child: Text(state.message));
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  Widget _buildImageDisplaySection(BuildContext context, File image) {
    return Card(
      color: Colors.blueAccent,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CustomIconButton(
              onTap: () {},
              icon: Icons.scanner_outlined,
              size: 25,
              data: 'Scanner',
            ),
            CustomIconButton(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecognizerPage(image: image),
                  ),
                );
              },
              icon: Icons.document_scanner_outlined,
              size: 25,
              data: 'Recognize Text',
            ),
            CustomIconButton(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EnhanceImagePage(image: image),
                  ),
                );
              },
              icon: Icons.assignment,
              size: 25,
              data: 'Enhance',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraOrImagePreview(DocumentScannerLoaded state, BuildContext context) {
    return Expanded(
      child: Card(
        child: state.isImageDisplayed
            ? Stack(
                children: [
                  Center(
                    child: Image.file(
                      state.capturedImage!,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        context.read<DocumentScannerBloc>().add(RemoveImageEvent());
                      },
                    ),
                  ),
                ],
              )
            : CameraPreview(state.cameraController),
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context) {
    return Card(
      color: Colors.blueAccent,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CustomIconButton(
              onTap: () {
                context.read<DocumentScannerBloc>().add(SwitchCameraEvent());
              },
              icon: Icons.rotate_left,
            ),
            CustomIconButton(
              onTap: () {
                context.read<DocumentScannerBloc>().add(CaptureImageEvent());
              },
              icon: Icons.camera,
              size: 50,
            ),
            CustomIconButton(
              onTap: () {
                context.read<DocumentScannerBloc>().add(PickImageFromGalleryEvent());
              },
              icon: Icons.image,
            ),
          ],
        ),
      ),
    );
  }
}

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    super.key,
    this.icon,
    this.size = 35.0,
    this.data,
    this.onTap,
  });

  final IconData? icon;
  final double size;
  final String? data;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(
            icon,
            size: size,
            color: Colors.white,
          ),
          data == null
              ? const SizedBox.shrink()
              : Text(
                  data!,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
        ],
      ),
    );
  }
}
