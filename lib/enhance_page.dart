// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:pro_image_editor/pro_image_editor.dart';
//
// class EnhanceImagePage extends StatefulWidget {
//   const EnhanceImagePage({super.key, required this.image});
//
//   final File image;
//
//   @override
//   State<EnhanceImagePage> createState() => _EnhanceImagePageState();
// }
//
// class _EnhanceImagePageState extends State<EnhanceImagePage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: ProImageEditor.file(widget.image, onImageEditingComplete: (imageBytes) async {}
//       ),
//     );
//   }
// }
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:logger/logger.dart';

class EnhanceImagePage extends StatefulWidget {
  const EnhanceImagePage({super.key, required this.image});

  final File image;

  @override
  State<EnhanceImagePage> createState() => _EnhanceImagePageState();
}

class _EnhanceImagePageState extends State<EnhanceImagePage> {

  // Function to request storage permissions
  Future<bool> _requestPermissions() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  // Function to save the image
  Future<void> _saveImage(Uint8List imageBytes) async {
    // Request permissions
    bool hasPermissions = await _requestPermissions();

    if (!hasPermissions) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission is required to save the image.')),
      );
      return;
    }

    try {
      // Define the directory and file name
      final directory = await getExternalStorageDirectory(); // For external storage
      // final imagePath = path.join(directory!.path, 'edited_image_${DateTime.now().millisecondsSinceEpoch}.png');
      final imagePath = path.join('/storage/emulated/0/', 'edited_image_${DateTime.now().millisecondsSinceEpoch}.png');

      // Save the image file
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(imageBytes);

      // Confirm the save operation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image saved in $imagePath')),
      );
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ProImageEditor.file(
        widget.image,
        onImageEditingComplete: (imageBytes) async {
          Logger().d('Image editing complete');
          await _saveImage(imageBytes);
        },
        allowCompleteWithEmptyEditing: true, // Handles the case where no edits are made
        onCloseEditor: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
