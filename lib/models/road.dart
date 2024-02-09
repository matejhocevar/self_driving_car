import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../constants/world_settings.dart';
import '../utils/canvas.dart';
import '../utils/math.dart';

class Road extends CustomPainter {
  Road({
    required this.x,
    required this.width,
    this.laneCount = 3,
  }) {
    left = x - width / 2;
    right = x + width / 2;
    borders = [
      [Offset(left, top), Offset(left, bottom)],
      [Offset(right, top), Offset(right, bottom)],
    ];
  }

  final double x;
  final double width;
  int laneCount;

  late final double left;
  late final double right;
  late List<List<Offset>> borders;

  double top = -WorldSettings.roadInfinity;
  double bottom = WorldSettings.roadInfinity;

  Road copyWith({
    double? x,
    double? width,
    int? laneCount,
  }) {
    return Road(
      x: x ?? this.x,
      width: width ?? this.width,
      laneCount: laneCount ?? this.laneCount,
    );
  }

  double getLaneCenter(int laneIndex) {
    final laneWidth = width / laneCount;
    return left +
        laneWidth / 2 +
        math.min(laneIndex, laneCount - 1) * laneWidth;
  }

  void update(double offsetY) {
    if ((top - offsetY).abs() < WorldSettings.roadRedrawThreshold) {
      top += -WorldSettings.roadInfinity;
      bottom += -WorldSettings.roadInfinity;

      borders = [
        [Offset(left, top), Offset(left, bottom)],
        [Offset(right, top), Offset(right, bottom)],
      ];
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 5;

    for (int i = 1; i <= laneCount - 1; i++) {
      double x = lerp(left, right, i / laneCount);

      var topOffset = Offset(x, top);
      var bottomOffset = Offset(x, bottom);

      drawDashedLine(
        canvas,
        topOffset,
        bottomOffset,
        roadPaint,
        dashWidth: 20,
        dashSpace: 20,
      );
    }

    borders.forEach((List<Offset> border) {
      canvas.drawLine(border[0], border[1], roadPaint);
    });
  }

  @override
  bool shouldRepaint(covariant Road oldDelegate) {
    return oldDelegate != this;
  }

  @override
  bool operator ==(Object other) {
    return other is Road &&
        x == other.x &&
        width == other.width &&
        laneCount == other.laneCount;
  }

  @override
  int get hashCode => Object.hash(x, width, laneCount);

  @override
  String toString() {
    return 'Road(x: $x, width: $width, laneCount: $laneCount)';
  }
}
