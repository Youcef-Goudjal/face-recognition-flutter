import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

bool checkEmail(String email) {
  return RegExp(r'^\w+[\w-\.]*\@\w+((-\w+)|(\w*))\.[a-z]{2,3}$')
      .hasMatch(email);
}

bool chekPassword(String mp) {
  return (mp.length >= 6);
}

ImageRotation rotationIntToImageRotation(int rotation) {
  switch (rotation) {
    case 0:
      return ImageRotation.rotation0;
    case 90:
      return ImageRotation.rotation90;
    case 180:
      return ImageRotation.rotation180;
    default:
      assert(rotation == 270);
      return ImageRotation.rotation270;
  }
}

Future<CameraDescription> getCamera(CameraLensDirection dir) async {
  return await availableCameras().then(
    (List<CameraDescription> cameras) => cameras.firstWhere(
      (CameraDescription camera) => camera.lensDirection == dir,
    ),
  );
}

List<Offset> Stringtoarray(String column) {
  List<Offset> l = List();

  List<String> s = column.split(RegExp(r'\)\(|,'));
  s[0] = s[0].substring(1);
  s[s.length - 1] = s[s.length - 1].substring(0, s[s.length - 1].length - 2);
  int i = 0;
  while (i < s.length) {
    double dx = double.parse(s[i]);
    double dy = double.parse(s[i + 1]);
    Offset offset = Offset(dx, dy);
    l.add(offset);

    i += 2;
  }
  return l;
}

FirebaseVisionImageMetadata buildMetaData(
  CameraImage image,
  ImageRotation rotation,
) {
  return FirebaseVisionImageMetadata(
    rawFormat: image.format.raw,
    size: Size(image.width.toDouble(), image.height.toDouble()),
    rotation: rotation,
    planeData: image.planes.map(
      (Plane plane) {
        return FirebaseVisionImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList(),
  );
}

Uint8List concatenatePlanes(List<Plane> planes) {
  final WriteBuffer allBytes = WriteBuffer();
  planes.forEach((Plane plane) => allBytes.putUint8List(plane.bytes));
  return allBytes.done().buffer.asUint8List();
}

Future<List<Face>> detect(
  CameraImage image,
  HandleDetection handleDetection,
  ImageRotation rotation,
) async {
  return handleDetection(
    FirebaseVisionImage.fromBytes(
      concatenatePlanes(image.planes),
      buildMetaData(image, rotation),
    ),
  );
}

typedef HandleDetection = Future<List<Face>> Function(
    FirebaseVisionImage image);
