import 'dart:io';

import 'package:document_scanner/bloc/enhance_bloc/enhance_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:pro_image_editor/pro_image_editor_main.dart';

class EnhanceImagePage extends StatelessWidget {
  const EnhanceImagePage({super.key, required this.image});

  final File image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<EnhanceBloc, EnhanceState>(
        listener: (context, state) {
          if (state is EnhanceLoading) {
            const Center(child: CircularProgressIndicator());
          } else if (state is EnhanceSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Successfully enhanced image')),
            );
          } else if (state is EnhanceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error encountered: ${state.error}')),
            );
          }
        },
        child: ProImageEditor.file(
          image,
          onImageEditingComplete: (imageBytes) async {
            context.read<EnhanceBloc>().add(SaveImage(imageBytes: imageBytes, context: context));
          },
          allowCompleteWithEmptyEditing: true,
          onCloseEditor: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
