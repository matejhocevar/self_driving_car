import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'controls.dart';
import 'sensor.dart';

class Car {
  Car({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.controls,
    this.speed = 0,
    this.angle = 0,
  }) {
    sensor = Sensor(
      car: this,
      rayCount: 5,
      rayLength: 150,
      raySpread: math.pi / 2,
    );
  }

  double x;
  double y;
  double width;
  double height;
  double speed;
  double angle;

  static const double friction = 0.05;
  static const double acceleration = 0.2;
  static const double maxSpeed = 3;
  static const double steerAngle = 0.03;

  late Sensor sensor;
  Controls controls;

  Car copyWith({
    double? x,
    double? y,
    double? width,
    double? height,
    double? speed,
    double? angle,
    Controls? controls,
  }) {
    return Car(
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      controls: controls ?? this.controls,
      speed: speed ?? this.speed,
      angle: angle ?? this.angle,
    );
  }

  void update(List<List<Offset>> roadBorders) {
    _move();
    sensor.update(roadBorders);
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
