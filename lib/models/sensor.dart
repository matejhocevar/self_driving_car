import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../utils/math.dart';
import 'car.dart';
import 'math.dart';

class Sensor extends CustomPainter {
  Sensor({
    required this.car,
    this.rayCount = 3,
    this.rayLength = 100,
    this.raySpread = math.pi / 4,
  });

  final Car car;
  final int rayCount;
  final double rayLength;
  final double raySpread;

  List<List<Offset>> rays = [];
  List<Position?> readings = [];

  void update(List<List<Offset>> roadBorders, List<Car> traffic) {
    _castRays();

    readings = [];
    for (int i = 0; i < rays.length; i++) {
      readings.add(
        _getReading(rays[i], roadBorders, traffic),
      );
    }
  }

  void _castRays() {
    rays = [];
    for (int i = 0; i < rayCount; i++) {
      double rayAngle = lerp(
            raySpread / 2,
            -raySpread / 2,
            rayCount == 1 ? 0.5 : i / (rayCount - 1),
          ) +
          car.angle;

      var start = Offset(car.x, car.y);
      var end = Offset(
        car.x - math.sin(rayAngle) * rayLength,
        car.y - math.cos(rayAngle) * rayLength,
      );
      rays.add([start, end]);
    }
  }

  Position? _getReading(
      List<Offset> ray, List<List<Offset>> roadBorders, List<Car> traffic) {
    final [rayStart, rayEnd] = ray;

    List<Position> touches = [];
    for (int i = 0; i < roadBorders.length; i++) {
      final [borderStart, borderEnd] = roadBorders[i];
      Position? touch = getIntersection(
        rayStart,
        rayEnd,
        borderStart,
        borderEnd,
      );

      if (touch != null) {
        touches.add(touch);
      }
    }

    for (int i = 0; i < traffic.length; i++) {
      var poly = traffic[i].polygon;
      for (int j = 0; j < poly.length; j++) {
        Position? touch = getIntersection(
          rayStart,
          rayEnd,
          poly[j],
          poly[(j + 1) % poly.length],
        );

        if (touch != null) {
          touches.add(touch);
        }
      }
    }

    if (touches.isEmpty) {
      return null;
    }
    var offsets = touches.map((Position p) => p.offset);
    double minOffset = offsets.reduce(math.min);
    return touches.firstWhere((Position p) => p.offset == minOffset);
  }

  @override
  void paint(Canvas canvas, Size size) {
    var readingPaint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 2;

    var sensorPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    for (int i = 0; i < rayCount; i++) {
      var [Offset start, Offset end] = rays[i];
      Offset reading = readings[i]?.position ?? end;
      canvas.drawLine(start, reading, readingPaint);
      canvas.drawLine(reading, end, sensorPaint);
    }
  }

  @override
  bool shouldRepaint(covariant Sensor oldDelegate) {
    return true;
  }
}
