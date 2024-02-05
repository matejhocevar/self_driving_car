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
