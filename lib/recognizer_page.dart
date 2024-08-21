import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class RecognizerPage extends StatefulWidget {
  const RecognizerPage({super.key, required this.image});

  final File image;

  @override
  State<RecognizerPage> createState() => _RecognizerPageState();
}

class _RecognizerPageState extends State<RecognizerPage> {
  late TextRecognizer _recognizer;
  String recognizedResultText = '';

  @override
  void initState() {
    _recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    doTextRecognition();
    super.initState();
  }

  doTextRecognition() async {
    final inputImage = InputImage.fromFile(widget.image);
    final RecognizedText recognizedText = await _recognizer.processImage(inputImage);

    recognizedResultText = recognizedText.text;
    setState(() {});
  }

  void copyToClipboard() {
    Clipboard.setData(ClipboardData(text: recognizedResultText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Text copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          title: const Text('Image Recognizer'),
          centerTitle: true,
        ),
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Image.file(widget.image),
                ),
                Expanded(
                  child: Column(
                    children: [
                      ColoredBox(
                        color: Colors.grey.shade400,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(width: 40),
                            const Text(
                              'Extracted Text',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 20),
                            IconButton(
                              icon: const Icon(Icons.copy_all),
                              tooltip: 'Copy All',
                              onPressed: copyToClipboard,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: SelectableText(
                            recognizedResultText,
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
