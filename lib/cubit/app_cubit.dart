import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(AppInitial());
  static AppCubit get(context) => BlocProvider.of(context);
  // var image;
  File? image;
  List? outPut;

  Future<void> imagePicker() async {
    try {
      var image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final imageTemporary = File(image.path);
      this.image = imageTemporary;
      emit(RefreshUIAppState());
    } on PlatformException catch (e) {
      print(e);
    }
  }

  classifyImage(File image) async {
    var outPut = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 2,
        threshold: 0.5,
        imageMean: 127.5,
        imageStd: 127.5);
    this.outPut = outPut;
    emit(RefreshUIAppState());
  }

  loadModel() async {
    await Tflite.loadModel(
        model: 'assets/model.tflite', labels: 'assets/labels.txt');
    emit(RefreshUIAppState());
  }

  @override
  void dispose() {
    Tflite.close();
    emit(RefreshUIAppState());
  }
}
