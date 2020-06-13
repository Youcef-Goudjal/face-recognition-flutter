import 'package:flutter/material.dart' show AnimatedBuilder, AnimationController, BuildContext, ClipPath, Color, Container, CustomClipper, Key, Offset, Path, Size, State, StatefulWidget, TickerProviderStateMixin, Widget;
import 'dart:math' as Math;

class WaveWidget extends StatefulWidget {
  final Size size;
  final double yOffset;
  final Color color;

  const WaveWidget({
    Key key,
    this.size,
    this.yOffset,
    this.color,
  }) : super(key: key);

  @override
  _WaveWidgetState createState() => _WaveWidgetState();
}

class _WaveWidgetState extends State<WaveWidget> with TickerProviderStateMixin {
  AnimationController animationController;
  List<Offset> wavePoint = [];

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 5000),
    )..addListener(() {
      wavePoint.clear();
      final double waveSpeed = animationController.value * 1080;
      final double fullSphere = animationController.value * Math.pi * 2;
      final double normalizer = Math.cos(fullSphere);
      final double waveWidth = Math.pi / 270;
      final double waveHeight = 20;
      for (int i = 0; i <= widget.size.width.toInt(); i++) {
        double calc = Math.sin((waveSpeed - i) * waveWidth);
        wavePoint.add(Offset(
            i.toDouble(), calc * waveHeight * normalizer + widget.yOffset));
      }

    });
    animationController.repeat();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: animationController,
        builder: (context, _) {
          return ClipPath(
            clipper: ClipperWidget(
              wavelist: wavePoint,
            ),
            child: Container(
              width: widget.size.width,
              height: widget.size.height,
              color: widget.color,
            ),
          );
        });
  }
}

class ClipperWidget extends CustomClipper<Path> {
  final List<Offset> wavelist;

  ClipperWidget({this.wavelist});

  @override
  getClip(Size size) {
    final Path path = Path();
    path.addPolygon(wavelist, false);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) => true;
}
