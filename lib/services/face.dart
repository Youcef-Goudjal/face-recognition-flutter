
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CustomFace {
  File _imagefile;
  List<Face> _faces;
  Image _image;
  final faceDetector = FirebaseVision.instance.faceDetector(FaceDetectorOptions(
    enableContours: true,
    enableLandmarks: true,
    enableTracking: true,
    mode: FaceDetectorMode.fast,
  ));

  Future<File> loadImage(bool source) async {
    File file;
    file = await ImagePicker.pickImage(
        source: (source) ? ImageSource.camera : ImageSource.gallery);
    _imagefile = file;
    return file;
  }

  Future<List<Face>> lookForFaces(File file) async {
    final image = FirebaseVisionImage.fromFile(file);
    List<Face> faces = await faceDetector.processImage(image);
    print("faces detected ${faces.length}");
    _faces = faces;
    return faces;
  }

  Future<Uint8List> face_to_img(Face face, File image) async {
    Rect rect = face.boundingBox;
    Uint8List bytes = await image.readAsBytes();
    // TODO: extract only the face from image
    //print(image.re);

    return bytes;
  }

//landmark_to_string(face.getContour(FaceContourType.allPoints).positionsList);
  String landmark_to_string(List<Offset> landmark) {
    String result = "{";
    for (int i = 0; i < landmark.length; i++) {

      result+='$i : { dx : ${landmark[i].dx.toStringAsFixed(4)} ; dy : ${landmark[i].dy.toStringAsFixed(4)}},\n';

    }
    result+="}";
    print(result);


  }
}