import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:print_color/print_color.dart';
import 'package:camera/camera.dart';
import 'package:face_rec/helpers/app_helper.dart';
import 'package:tflite/tflite.dart';

class TFLiteHelper {
  static StreamController<List> tfLiteResultsController =
      new StreamController.broadcast();
  static List output = List();
  static var modelLoaded = false;

  static Future<String> loadModel() async {
    AppHelper.log("loadModel", "Loading model ..");
    return Tflite.loadModel(
        model: "assets/mobile_face_net.tflite",
        labels: "assets/label.txt",
        useGpuDelegate: true);
  }

  static classifyImage(CameraImage image) async {
    await Tflite.runModelOnFrame(
      bytesList: image.planes.map((e) => e.bytes).toList(),
    ).then((value) {
      if (value.isNotEmpty) {
        AppHelper.log("classifyImage", "Results loaded. ${value.length}");
        print(value);
        //clear Previous results
        Print.red(value);
        output.clear();
      }
    });
  }

  static classifyImage2(File image) async {
    await Tflite.runModelOnImage(path: image.path).then((value) {
      print(value);
    });
  }

  static void disposeModel() {
    Tflite.close();
    tfLiteResultsController.close();
  }
}
