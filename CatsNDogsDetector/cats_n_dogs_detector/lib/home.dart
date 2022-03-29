import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final picker = ImagePicker();
  late File _image;
  late bool _loading = false;
  late List _output;

  takeImage() async {
    var image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return null;
    setState(() {
      _image = File(image.path);
    });
    classifyImage(_image);
  }

  pickGalleryImage() async {
    var image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      _image = File(image.path);
    });
    classifyImage(_image);
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
  }

  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: _image.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    // print(output);
    setState(() {
      _loading = false;
      _output = output!;
    });
  }

  @override
  void initState() {
    super.initState();
    _loading = true;
    loadModel().then((value) {
      return print("Model loaded");
    });
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF101010),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 100),
              const Text(
                'Teachable Machine CNN',
                style: TextStyle(
                    color: Color(0xFFEEDA28),
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Detect Dogs and Cats',
                style: TextStyle(
                  color: Color(0xffe99600),
                  fontWeight: FontWeight.w500,
                  fontSize: 28,
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              Center(
                child: _loading
                    ? SizedBox(
                        width: 300,
                        child: Column(children: [
                          Image.asset('assets/images/cat.png'),
                          const SizedBox(height: 50),
                        ]),
                      )
                    : Container(
                        child: Column(
                        children: [
                          SizedBox(
                            height: 250,
                            child: Image.file(_image),
                          ),
                          const SizedBox(height: 20),
                          if (_output != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 20),
                              child: Text(
                                _output[0]["label"],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          else
                            Container(),
                        ],
                      )),
              ),
              SizedBox(
                //Button to Pick an Image from Camera
                width: MediaQuery.of(context).size.width,
                child: Column(children: [
                  GestureDetector(
                    onTap: takeImage,
                    child: Container(
                      width: MediaQuery.of(context).size.width - 260,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 17),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE99600),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Take a Photo',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    //Button to Pick an Image from Gallery
                    onTap: pickGalleryImage,
                    child: Container(
                      width: MediaQuery.of(context).size.width - 260,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 17),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE99600),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'CameraRoll',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ]),
              )
            ],
          ),
        ));
  }
}
