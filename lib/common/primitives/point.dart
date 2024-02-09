import 'package:flutter/material.dart';

class Point extends CustomPainter {
  const Point(this.x, this.y);

  final double x;
  final double y;

  Offset get offset => Offset(x, y);

  @override
  void paint(
    Canvas canvas,
    Size size, {
    double radius = 18,
    Color color = Colors.black87,
  }) {
    canvas.drawCircle(offset, radius / 2, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) =>
      oldDelegate != this;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Point && x == other.x && y == other.y;
  }

  @override
  int get hashCode => Object.hash(x, y);
}
