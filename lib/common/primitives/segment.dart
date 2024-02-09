import 'package:flutter/material.dart';

import 'point.dart';

class Segment extends CustomPainter {
  const Segment(this.p1, this.p2);

  final Point p1;
  final Point p2;

  bool includes(Point p) {
    return p1 == p || p2 == p;
  }

  @override
  void paint(
    Canvas canvas,
    Size size, {
    double width = 2,
    Color color = Colors.black87,
  }) {
    canvas.drawLine(
      p1.offset,
      p2.offset,
      Paint()
        ..color = color
        ..strokeWidth = width,
    );
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
}
