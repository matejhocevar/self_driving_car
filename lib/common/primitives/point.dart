import 'package:flutter/material.dart';

import '../../virtual_world/settings.dart';

class Point extends CustomPainter {
  Point(this.x, this.y);

  double x;
  double y;

  Point.fromOffset(Offset o)
      : x = o.dx,
        y = o.dy;

  Offset get offset => Offset(x, y);

  @override
  void paint(
    Canvas canvas,
    Size size, {
    double radius = 18,
    Color color = Colors.black87,
    bool outline = false,
    bool fill = false,
  }) {
    canvas.drawCircle(
      offset,
      radius / 2,
      Paint()..color = color,
    );

    if (outline) {
      canvas.drawCircle(
        offset,
        radius / 2 * 0.6,
        VirtualWorldSettings.graphEditorSelectedPaint
          ..style = PaintingStyle.stroke,
      );
    }

    if (fill) {
      canvas.drawCircle(
        offset,
        radius / 2 * 0.4,
        VirtualWorldSettings.graphEditorHoveredPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) =>
      oldDelegate != this;

  @override
  String toString() {
    return 'Point($x, $y)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Point && x == other.x && y == other.y;
  }

  @override
  int get hashCode => Object.hash(x, y);
}
