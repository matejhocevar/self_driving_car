import 'package:flutter/material.dart';
import 'package:self_driving_car/painters/sensor_painter.dart';

import '../models/car.dart';

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

    SensorPainter(sensor: car.sensor).paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CarPainter oldDelegate) {
    return true;
  }
}
