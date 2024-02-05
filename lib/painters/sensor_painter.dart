import 'package:flutter/material.dart';

import '../models/sensor.dart';

class SensorPainter extends CustomPainter {
  const SensorPainter({required this.sensor});

  final Sensor sensor;

  @override
  void paint(Canvas canvas, Size size) {
    var readingPaint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 2;

    var sensorPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    for (int i = 0; i < sensor.rayCount; i++) {
      var [Offset start, Offset end] = sensor.rays[i];
      Offset reading = sensor.readings[i]?.position ?? end;
      canvas.drawLine(start, reading, readingPaint);
      canvas.drawLine(reading, end, sensorPaint);
    }
  }

  @override
  bool shouldRepaint(covariant SensorPainter oldDelegate) {
    return true;
  }
}
