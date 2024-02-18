import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:self_driving_car/utils/canvas.dart';

import '../../utils/math.dart';
import 'point.dart';

class Segment extends CustomPainter {
  Segment(this.p1, this.p2, {this.oneWay = false});

  Point p1;
  Point p2;
  bool oneWay;

  (Point, Point) get points => (p1, p2);

  bool includes(Point p) {
    return p1 == p || p2 == p;
  }

  double length() {
    return distance(p1, p2);
  }

  Point directionVector() {
    return normalize(subtract(p2, p1));
  }

  double distanceToPoint(Point p) {
    final (Point projPoint, double projOffset) = projectPoint(p);
    if (projOffset > 0 && projOffset < 1) {
      return distance(p, projPoint);
    }

    double distToP1 = distance(p, p1);
    double distToP2 = distance(p, p2);
    return math.min(distToP1, distToP2);
  }

  (Point point, double offset) projectPoint(Point p) {
    Point a = subtract(p, p1);
    Point b = subtract(p2, p1);
    Point normB = normalize(b);
    double scaler = dot(a, normB);
    return (
      add(p1, scale(normB, scaler)),
      scaler / magnitude(b),
    );
  }

  @override
  void paint(
    Canvas canvas,
    Size size, {
    double width = 2,
    Color color = Colors.black87,
    List<int> dash = const [],
    bool showPartialDash = false,
    StrokeCap strokeCap = StrokeCap.butt,
  }) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = strokeCap;

    if (oneWay) {
      dash = [4, 4];
    }

    if (dash.isNotEmpty) {
      final [int dashSpace, int dashWidth] = dash;
      drawDashedLine(
        canvas,
        p1.offset,
        p2.offset,
        paint,
        dashSpace: dashSpace,
        dashWidth: dashWidth,
        showPartialLines: showPartialDash,
      );
    } else {
      canvas.drawLine(p1.offset, p2.offset, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) =>
      oldDelegate != this;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Segment && includes(other.p1) && includes(other.p2);
  }

  @override
  int get hashCode => Object.hash(p1, p2);

  List<double> toJSON() {
    return [p1.x, p1.y, p2.x, p2.y];
  }

  static Segment load(
    List<dynamic> rawSegment, {
    List<Point> points = const [],
  }) {
    final [p1x, p1y, p2x, p2y] = List<double>.from(rawSegment);
    late Point p1;
    late Point p2;
    if (points.isNotEmpty) {
      p1 = points.firstWhere((Point pp) => pp.x == p1x && pp.y == p1y);
      p2 = points.firstWhere((Point pp) => pp.x == p2x && pp.y == p2y);
    } else {
      p1 = Point(p1x, p1y);
      p2 = Point(p2x, p2y);
    }
    return Segment(p1, p2);
  }
}
