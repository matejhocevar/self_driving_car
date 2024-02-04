import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'controls.dart';

class Car extends CustomPainter {
  Car({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.controls,
  });

  double x;
  double y;
  double width;
  double height;

  double speed = 0;
  double angle = 0;
  static const double friction = 0.05;
  static const double acceleration = 0.2;
  static const double maxSpeed = 3;
  static const double steerAngle = 0.03;

  Controls controls;

  void update() {
    _move();
  }

  void _move() {
    if (controls.forward) {
      speed += Car.acceleration;
    }
    if (controls.reverse) {
      speed -= Car.acceleration;
    }

    if (speed > Car.maxSpeed) {
      speed = Car.maxSpeed;
    }

    if (speed < -Car.maxSpeed / 2) {
      speed = -Car.maxSpeed / 2;
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

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(-angle);
    canvas.drawRect(
      Rect.fromLTWH(-width / 2, -height / 2, width, height),
      Paint()..color = Colors.black,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant Car oldDelegate) {
    return identical(this, oldDelegate);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Car &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y &&
          width == other.width &&
          height == other.height &&
          controls == other.controls;

  @override
  int get hashCode =>
      x.hashCode +
      y.hashCode +
      width.hashCode +
      height.hashCode +
      controls.hashCode;

  @override
  String toString() {
    return 'Car(x: $x, y: $y, width: $width, height: $height)';
  }
}
