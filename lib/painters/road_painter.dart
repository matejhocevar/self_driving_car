import 'package:flutter/material.dart';

import '../models/road.dart';
import '../utils/canvas.dart';
import '../utils/math.dart';

class RoadPainter extends CustomPainter {
  RoadPainter({
    required this.road,
  });

  final Road road;

  @override
  void paint(Canvas canvas, Size size) {
    Paint roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 5;

    for (int i = 1; i <= road.laneCount - 1; i++) {
      double x = lerp(road.left, road.right, i / road.laneCount);

      var topOffset = Offset(x, road.top);
      var bottomOffset = Offset(x, road.bottom);

      drawDashedLine(
        canvas,
        topOffset,
        bottomOffset,
        roadPaint,
        dashWidth: 20,
        dashSpace: 20,
      );
    }

    road.borders.forEach((List<Offset> border) {
      canvas.drawLine(border[0], border[1], roadPaint);
    });
  }

  @override
  bool shouldRepaint(covariant RoadPainter oldDelegate) {
    return oldDelegate.road != road;
  }
}
