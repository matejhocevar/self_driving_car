import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/math.dart';

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

double hypot(double x, double y) {
  return math.sqrt(math.pow(x, 2) + math.pow(y, 2));
}
