import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../common/primitives/point.dart';
import '../../common/primitives/polygon.dart';
import '../../utils/math.dart';

class Tree extends CustomPainter {
  const Tree(
    this.center,
    this.radius, {
    this.heightCoef = 0.3,
    this.layers = 7,
  });

  final Point center;
  final double radius;
  final double heightCoef;
  final int layers;

  Polygon get base => _generateLevel(center, radius);

  Polygon _generateLevel(Point point, double radius) {
    List<Point> points = [];
    for (double a = 0; a < math.pi * 2; a += math.pi / 16) {
      double random =
          math.pow(math.cos(((a + center.x) * radius) % 17), 2).toDouble();
      double noisyRadius = radius * lerp(0.5, 1, random);
      points.add(translate(point, a, noisyRadius));
    }
    return Polygon(points);
  }

  @override
  void paint(
    Canvas canvas,
    Size size, {
    Point? viewPoint,
  }) {
    Point diff = subtract(center, viewPoint ?? Point(0, 0));
    Point top = add(center, scale(diff, heightCoef));

    for (int level = 0; level < layers; level++) {
      final t = level / (layers - 1);
      final point = lerp2D(center, top, t);
      final color = Color.fromRGBO(30, lerp(50, 200, t).toInt(), 70, 1);
      final levelRadius = lerp(radius, 40, t);

      Polygon polygon = _generateLevel(point, levelRadius);
      polygon.paint(canvas, size, fill: color);
    }
  }

  @override
  bool shouldRepaint(covariant Tree oldDelegate) =>
      center != oldDelegate.center || radius != oldDelegate.radius;
}
