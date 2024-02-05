import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:self_driving_car/network.dart';

import '../utils/math.dart';
import 'controls.dart';
import 'math.dart';
import 'sensor.dart';

class Car extends CustomPainter {
  Car({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.maxSpeed = 3,
    this.controlType = ControlType.dummy,
    this.speed = 0,
    this.angle = 0,
    this.color = Colors.blue,
  }) {
    useBrain = controlType == ControlType.AI;

    if (controlType != ControlType.dummy) {
      sensor = Sensor(
        car: this,
        rayCount: 5,
        rayLength: 150,
        raySpread: math.pi / 2,
      );
      brain = NeuralNetwork(neuronCounts: [sensor.rayCount, 6, 4]);
    }

    polygon = _createPolygon();
    controls = Controls(type: controlType);
  }

  double x;
  double y;
  double width;
  double height;
  double speed;
  double angle;
  double maxSpeed;
  Color color;

  static const double friction = 0.05;
  static const double acceleration = 0.2;
  static const double steerAngle = 0.03;
  bool damaged = false;

  late Sensor sensor;
  late Controls controls;
  final ControlType controlType;
  late NeuralNetwork brain;
  bool useBrain = false;

  late List<Offset> polygon;

  Car copyWith({
    double? x,
    double? y,
    double? width,
    double? height,
    double? speed,
    double? angle,
    ControlType? controlType,
    Color? color,
  }) {
    return Car(
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      controlType: controlType ?? this.controlType,
      speed: speed ?? this.speed,
      angle: angle ?? this.angle,
      color: color ?? this.color,
    );
  }

  void update(List<List<Offset>> roadBorders, List<Car> traffic) {
    if (!damaged) {
      _move();
      polygon = _createPolygon();
      damaged = _assessDamage(roadBorders, traffic);
    }

    if (controlType != ControlType.dummy) {
      sensor.update(roadBorders, traffic);
      List<double> offsets = sensor.readings
          .map((Position? p) => p?.offset == null ? 0.0 : 1 - p!.offset)
          .toList();
      List<double> outputs = NeuralNetwork.feedForward(offsets, brain);

      if (useBrain) {
        controls.forward = outputs[0] > 0;
        controls.left = outputs[1] > 0;
        controls.right = outputs[2] > 0;
        controls.reverse = outputs[3] > 0;
      }
      print(outputs);
    }
  }

  List<Offset> _createPolygon() {
    double radius = hypot(width, height) / 2;
    double alpha = math.atan2(width, height);
    return [
      Offset(
        x - math.sin(angle - alpha) * radius,
        y - math.cos(angle - alpha) * radius,
      ),
      Offset(
        x - math.sin(angle + alpha) * radius,
        y - math.cos(angle + alpha) * radius,
      ),
      Offset(
        x - math.sin(math.pi + angle - alpha) * radius,
        y - math.cos(math.pi + angle - alpha) * radius,
      ),
      Offset(
        x - math.sin(math.pi + angle + alpha) * radius,
        y - math.cos(math.pi + angle + alpha) * radius,
      ),
    ];
  }

  void _move() {
    if (controls.forward) {
      speed += Car.acceleration;
    }
    if (controls.reverse) {
      speed -= Car.acceleration;
    }

    if (speed > maxSpeed) {
      speed = maxSpeed;
    }

    if (speed < -maxSpeed / 2) {
      speed = -maxSpeed / 2;
    }

    if (speed > 0) {
      speed -= Car.friction;
    }

    if (speed < 0) {
      speed += Car.friction;
    }

    if (speed != 0) {
      int flip = speed > 0 ? 1 : -1;

      if (controls.left) {
        angle += Car.steerAngle * flip;
      }

      if (controls.right) {
        angle -= Car.steerAngle * flip;
      }
    }

    x -= math.sin(angle) * speed;
    y -= math.cos(angle) * speed;
  }

  bool _assessDamage(List<List<Offset>> roadBorders, List<Car> traffic) {
    for (int i = 0; i < roadBorders.length; i++) {
      if (polysIntersect(polygon, roadBorders[i])) {
        return true;
      }
    }

    for (int i = 0; i < traffic.length; i++) {
      if (polysIntersect(polygon, traffic[i].polygon)) {
        return true;
      }
    }

    return false;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var carPaint = Paint()
      ..color = damaged ? Colors.redAccent : color
      ..style = PaintingStyle.fill;

    Path path = Path();
    path.moveTo(polygon.first.dx, polygon.first.dy);
    for (int i = 1; i < polygon.length; i++) {
      path.lineTo(polygon[i].dx, polygon[i].dy);
    }

    canvas.drawPath(path, carPaint);

    if (controlType != ControlType.dummy) {
      sensor.paint(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant Car oldDelegate) {
    return true;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Car &&
            runtimeType == other.runtimeType &&
            x == other.x &&
            y == other.y &&
            width == other.width &&
            height == other.height &&
            controls == other.controls;
  }

  @override
  int get hashCode => Object.hash(x, y, width, height, controls);

  @override
  String toString() {
    return 'Car(x: $x, y: $y, width: $width, height: $height)';
  }
}
