import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../utils/math.dart';
import 'point.dart';
import 'polygon.dart';
import 'segment.dart';

class Envelope extends CustomPainter {
  Envelope(this.skeleton, {required this.width, this.roundness = 1}) {
    polygon = _generatePolygon(width, roundness: roundness);
  }

  final Segment skeleton;
  final double width;
  final int roundness;
  late Polygon polygon;

  Polygon _generatePolygon(width, {int roundness = 10}) {
    final (Point p1, Point p2) = skeleton.points;
    final double radius = width / 2;
    final alpha = angle(subtract(p1, p2));
    final alphaCw = alpha + math.pi / 2;
    final alphaCcw = alpha - math.pi / 2;

    final List<Point> points = [];
    final double step = math.pi / math.max(roundness, 1);
    final double eps = step / 2;
    for (double i = alphaCcw; i <= alphaCw + eps; i += step) {
      points.add(translate(p1, i, radius));
    }
    for (double i = alphaCcw; i <= alphaCw + eps; i += step) {
      points.add(translate(p2, math.pi + i, radius));
    }

    return Polygon(points);
  }

  @override
  void paint(
    Canvas canvas,
    Size size, {
    Color fill = Colors.transparent,
    Color stroke = Colors.transparent,
    double lineWidth = 0,
  }) {
    polygon.paint(
      canvas,
      size,
      fill: fill,
      stroke: stroke,
      lineWidth: lineWidth,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
