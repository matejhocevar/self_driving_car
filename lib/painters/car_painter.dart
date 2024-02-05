import 'package:flutter/material.dart';

import '../car.dart';

class CarPainter extends CustomPainter {
  const CarPainter({required this.car});

  final Car car;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(car.x, car.y);
    canvas.rotate(-car.angle);
    canvas.drawRect(
      Rect.fromLTWH(-car.width / 2, -car.height / 2, car.width, car.height),
      Paint()..color = Colors.black,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CarPainter oldDelegate) {
    return true;
  }
}
