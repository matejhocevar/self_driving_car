import 'package:flutter/material.dart';

import '../../virtual_world/settings.dart';

class Point extends CustomPainter {
  Point(this.x, this.y);

  double x;
  double y;
  int? id;

  Point.fromOffset(Offset o)
      : x = o.dx,
        y = o.dy;

  Offset get offset => Offset(x, y);

  @override
  void paint(
    Canvas canvas,
    Size size, {
    double radius = 9,
    Color color = Colors.black87,
    bool outline = false,
    bool fill = false,
  }) {
    canvas.drawCircle(
      offset,
      radius,
      Paint()..color = color,
    );

    if (outline) {
      canvas.drawCircle(
        offset,
        radius * 0.6,
        VirtualWorldSettings.editorSelectedPaint..style = PaintingStyle.stroke,
      );
    }

    if (fill) {
      canvas.drawCircle(
        offset,
        radius * 0.4,
        VirtualWorldSettings.editorHoveredPaint,
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

  List<double> toJSON() {
    return [x, y];
  }

  static Point fromJSON(List<double> json) {
    return Point(json[0], json[1]);
  }
}
