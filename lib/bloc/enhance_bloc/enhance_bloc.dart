import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

part 'enhance_event.dart';

part 'enhance_state.dart';

class EnhanceBloc extends Bloc<EnhanceEvent, EnhanceState> {
  EnhanceBloc() : super(EnhanceInitial()) {
    on<SaveImage>(_onSaveImage);
    on<RequestPermissions>(_onRequestPermissions);
  }

  Future<void> _onSaveImage(SaveImage event, Emitter<EnhanceState> emit) async {
    emit(EnhanceLoading());

    bool hasPermissions = await _requestPermissions();

    if (!hasPermissions) {
      ScaffoldMessenger.of(event.context).showSnackBar(
        const SnackBar(content: Text('Storage permission is required to save the image.')),
      );
      emit(EnhanceError(error: 'Permission denied'));
      return;
    }

    try {
      final directory = await getExternalStorageDirectory();
      final imagePath = path.join('/storage/emulated/0/', 'edited_image_${DateTime.now().millisecondsSinceEpoch}.png');

      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(event.imageBytes);

      ScaffoldMessenger.of(event.context).showSnackBar(
        SnackBar(content: Text('Image saved in $imagePath')),
      );
      emit(EnhanceSuccess(imagePath: imagePath));
    } catch (e) {
      emit(EnhanceError(error: 'Failed to save image: $e'));
    }
  }

  Future<void> _onRequestPermissions(RequestPermissions event, Emitter<EnhanceState> emit) async {
    bool granted = await _requestPermissions();
    if (!granted) {
      emit(EnhanceError(error: 'Permission denied'));
    }
  }

  Future<bool> _requestPermissions() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }
}
