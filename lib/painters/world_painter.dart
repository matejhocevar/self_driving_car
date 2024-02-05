import 'package:flutter/material.dart';

import 'car_painter.dart';
import 'road_painter.dart';

class WorldPainter extends CustomPainter {
  const WorldPainter({
    required this.roadPainter,
    required this.carPainter,
  });

  final RoadPainter roadPainter;
  final CarPainter carPainter;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    canvas.translate(0, -carPainter.car.y + size.height * 0.7);

    roadPainter.paint(canvas, size);
    carPainter.paint(canvas, size);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
