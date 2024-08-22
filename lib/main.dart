import 'package:document_scanner/bloc/doc_scanner_bloc/document_scanner_bloc.dart';
import 'package:document_scanner/bloc/enhance_bloc/enhance_bloc.dart';
import 'package:document_scanner/bloc/recognizer_bloc/recognizer_bloc.dart';
import 'package:document_scanner/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => DocumentScannerBloc(imagePicker: ImagePicker()),
        ),
        BlocProvider(
          create: (context) => EnhanceBloc(),
        ),
        BlocProvider(
          create: (context) => RecognizerBloc(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}
