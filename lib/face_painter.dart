import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';

class CustomFace extends CustomPainter {
  final Size imageSize;
  final List<Face> faces;
  CameraLensDirection dir = CameraLensDirection.back;

  CustomFace(this.imageSize, this.faces, [this.dir]);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < faces.length; i++) {
      //Scale rect to image size
      final rect = _scaleRect(
          rect: faces[i].boundingBox,
          imageSize: imageSize,
          widgetSize: size,
          dir: dir);
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(CustomFace oldDelegate) => true;
}

Rect _scaleRect(
    {@required Rect rect,
    @required Size imageSize,
    @required Size widgetSize,
    CameraLensDirection dir}) {
  final double scaleX = widgetSize.width / imageSize.width;
  final double scaleY = widgetSize.height / imageSize.height;
  if (dir == CameraLensDirection.front) {
    double left = rect.topRight.dx.toDouble();
    double center = imageSize.width / 2;
    if (left >= center) {
      left = left - 2 * (left - center);
    } else {
      left = left + 2 * (center - left);
    }
    return Rect.fromLTWH(
      left * scaleX,
      rect.topRight.dy * scaleY,
      rect.width * scaleX,
      rect.height* scaleY,
    );
  }
  return Rect.fromLTRB(
    rect.left.toDouble() * scaleX,
    rect.top.toDouble() * scaleY,
    rect.right.toDouble() * scaleX,
    rect.bottom.toDouble() * scaleY,
  );
}
