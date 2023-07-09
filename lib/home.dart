import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/app_cubit.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _loading = true;
  File? _image;
  List? _outPut;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loadModel().then((value) {
      setState(() {});
    });
  }

  classifyImage(File image) async {
    var outPut = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 2,
        threshold: 0.5,
        imageMean: 127.5,
        imageStd: 127.5);
    setState(() {
      _outPut = outPut!;
      _loading = false;
    });
  }

  loadModel() async {
    await Tflite.loadModel(
        model: 'assets/model.tflite', labels: 'assets/labels.txt');
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  pickImage() async {
    var image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() {
      _image = File(image.path);
    });

    classifyImage(_image!);
  }

  @override
  Widget build(BuildContext context) {
    // return BlocConsumer<AppCubit, AppState>(
    //   listener: (context, state) {},
    //   builder: (context, state) {
    //     AppCubit appCubit = AppCubit.get(context);
    return Scaffold(
      body: Center(
          child: Column(
        children: [
          _image != null
              ? Image.file(
                  _image!,
                  width: 160,
                  height: 160,
                )
              : const FlutterLogo(
                  size: 160,
                ),
          Row(
            children: [
              TextButton(
                  onPressed: () {
                    pickImage();
                  },
                  child: const Text(
                    "pick",
                    style: TextStyle(fontSize: 30),
                  ))
            ],
          ),
          const SizedBox(
            height: 150,
          ),
          _outPut != null
              ? Text('${_outPut![0]}')
              : Container(
                  child: Text(
                    'nothing',
                    style: TextStyle(color: Colors.red),
                  ),
                )
        ],
      )),
    );
  }
}
//     );
//   }
// }
