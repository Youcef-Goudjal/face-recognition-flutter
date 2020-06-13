import 'package:app/services/face.dart';
import 'package:app/util/utilitis.dart';
import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';

class LiveCamera extends StatefulWidget {
  CameraController camera;
  List list; // known faces from DB

  LiveCamera(this.list, {this.camera});

  @override
  _LiveCameraState createState() => _LiveCameraState();
}

class _LiveCameraState extends State<LiveCamera> {
  final CustomFace faceDetector = CustomFace();
  List<Face> faces; //unknown faces
  CameraDescription description;

  bool isDetecting = false;
  CameraLensDirection _direction =
      CameraLensDirection.back; // initial camera (back)

  @override
  void initState() {
    super.initState();
    _initializeCamera().then((v) {
      setState(() {});
    });
  }

  Future<void> _initializeCamera() async {
    description = await getCamera(_direction);
    ImageRotation rotation =
        rotationIntToImageRotation(description.sensorOrientation);
    widget.camera = CameraController(description, ResolutionPreset.low);
    await widget.camera.initialize();
    widget.camera.startImageStream((image) {
      if (isDetecting) return;
      isDetecting = true;
      detect(image, faceDetector.faceDetector.processImage, rotation)
          .then((result) {
            
      });
      isDetecting = false;
    });
  }

  void _toggleCameraDirection() async {
    if (_direction == CameraLensDirection.back) {
      _direction = CameraLensDirection.front;
    } else {
      _direction = CameraLensDirection.back;
    }

    await widget.camera.stopImageStream();
    await widget.camera.dispose();

    setState(() {
      widget.camera = null;
    });

    _initializeCamera().then((value) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    widget.camera.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.expand(),
      child: widget.camera == null
          ? Center(
              child: Text(
                'Initializing Camera...',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 30.0,
                ),
              ),
            )
          : Stack(
              children: <Widget>[
                CameraPreview(widget.camera),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: IconButton(
                      icon: Icon(
                        _direction == CameraLensDirection.back
                            ? Icons.camera_alt
                            : Icons.camera_front,
                        size: 40,
                      ),
                      onPressed: () {
                        _toggleCameraDirection();
                        setState(() {});
                      }),
                )
              ],
            ),
    );
  }
}
