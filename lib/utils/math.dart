import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../common/primitives/point.dart';
import '../common/primitives/position.dart';
import '../common/primitives/segment.dart';

double lerp(double a, double b, double t) {
  return a + (b - a) * t;
}

Point lerp2D(Point a, Point b, double t) {
  return Point(
    lerp(a.x, b.x, t),
    lerp(a.y, b.y, t),
  );
}

double invLerp(double a, double b, double v) {
  return (v - a) / (b - a);
}

double degToRad(degree) {
  return degree * math.pi / 180;
}

Position? getIntersection(Offset a, Offset b, Offset c, Offset d) {
  final tTop = (d.dx - c.dx) * (a.dy - c.dy) - (d.dy - c.dy) * (a.dx - c.dx);
  final uTop = (c.dy - a.dy) * (a.dx - b.dx) - (c.dx - a.dx) * (a.dy - b.dy);
  final bottom = (d.dy - c.dy) * (b.dx - a.dx) - (d.dx - c.dx) * (b.dy - a.dy);

  const double eps = 0.001;
  if (bottom.abs() > eps) {
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

Segment? getNearestSegment(
  Point point,
  List<Segment> segments, {
  double threshold = double.infinity,
}) {
  double minDist = double.infinity;
  Segment? nearest;

  for (Segment s in segments) {
    double dist = s.distanceToPoint(point);
    if (dist < minDist && dist < threshold) {
      minDist = dist;
      nearest = s;
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

Point average(Point p1, Point p2) {
  return Point((p1.x + p2.x) / 2, (p1.y + p2.y) / 2);
}

double dot(Point p1, Point p2) {
  return p1.x * p2.x + p1.y * p2.y;
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

Point normalize(Point p) {
  return scale(p, 1 / magnitude(p));
}

double magnitude(Point p) {
  return hypot(p.x, p.y);
}

Point perpendicular(Point p) {
  return Point(-p.y, p.x);
}

Point translate(p, angle, offset) {
  return Point(
    p.x + math.cos(angle) * offset,
    p.y + math.sin(angle) * offset,
  );
}

double angle(Point p) {
  return math.atan2(p.y, p.x);
}

Point getFake3DPoint(Point p, Point viewPoint, double height) {
  Point dir = normalize(subtract(p, viewPoint));
  double dist = distance(p, viewPoint);
  double scaler = math.atan(dist / 300) / (math.pi / 2);
  return add(p, scale(dir, height * scaler));
}
