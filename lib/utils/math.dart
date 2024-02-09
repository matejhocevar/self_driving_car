import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../common/primitives/point.dart';
import '../common/primitives/position.dart';

double lerp(double a, double b, double t) {
  return a + (b - a) * t;
}

Position? getIntersection(Offset a, Offset b, Offset c, Offset d) {
  final tTop = (d.dx - c.dx) * (a.dy - c.dy) - (d.dy - c.dy) * (a.dx - c.dx);
  final uTop = (c.dy - a.dy) * (a.dx - b.dx) - (c.dx - a.dx) * (a.dy - b.dy);
  final bottom = (d.dy - c.dy) * (b.dx - a.dx) - (d.dx - c.dx) * (b.dy - a.dy);

  if (bottom != 0) {
    final t = tTop / bottom;
    final u = uTop / bottom;

    if (t >= 0 && t <= 1 && u >= 0 && u <= 1) {
      return Position(
        position: Offset(
          lerp(a.dx, b.dx, t),
          lerp(a.dy, b.dy, t),
        ),
        offset: t,
      );
    }
  }
}

Point? getNearestPoint(
  Point point,
  List<Point> points, {
  double threshold = double.infinity,
}) {
  double minDist = double.infinity;
  Point? nearest;

  for (Point p in points) {
    double dist = distance(p, point);
    if (dist < minDist && dist < threshold) {
      minDist = dist;
      nearest = p;
    }
  }
  return nearest;
}

bool polysIntersect(List<Offset> p1, List<Offset> p2) {
  for (int i = 0; i < p1.length; i++) {
    for (int j = 0; j < p2.length; j++) {
      Position? touch = getIntersection(
        p1[i],
        p1[(i + 1) % p1.length],
        p2[j],
        p2[(j + 1) % p2.length],
      );
      if (touch != null) {
        return true;
      }
    }
  }

  return false;
}

double distance(Point p1, Point p2) {
  return hypot(p1.x - p2.x, p1.y - p2.y);
}

double hypot(double x, double y) {
  return math.sqrt(math.pow(x, 2) + math.pow(y, 2));
}

Point add(Point p1, Point p2) {
  return Point(p1.x + p2.x, p1.y + p2.y);
}

Point subtract(Point p1, Point p2) {
  return Point(p1.x - p2.x, p1.y - p2.y);
}

Point scale(Point p, double scale) {
  return Point(p.x * scale, p.y * scale);
}

extension RGBA on double {
  Color toRGBA() {
    double value = this;
    double opacity = value.abs();
    int r = value < 0 ? 0 : 255;
    int g = r;
    int b = value > 0 ? 0 : 255;

    return Color.fromRGBO(r, g, b, opacity);
  }
}
