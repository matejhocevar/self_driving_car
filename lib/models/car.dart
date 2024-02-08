import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../constants/world_settings.dart';
import '../network/network.dart';
import '../utils/math.dart';
import 'controls.dart';
import 'math.dart';
import 'sensor.dart';
import 'vehicle.dart';

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
    this.brain,
    this.vehicle,
    this.vehicleOpacity = 1,
  }) {
    useBrain = controlType == ControlType.AI;

    if (controlType != ControlType.dummy) {
      sensor = Sensor(
        car: this,
        rayCount: WorldSettings.sensorRayCount,
        rayLength: WorldSettings.sensorRayLength,
        raySpread: WorldSettings.sensorRaySpread,
      );
      brain = brain ??
          NeuralNetwork(neuronCounts: [
            sensor.rayCount,
            WorldSettings.neuralNetworkLevel1Count,
            WorldSettings.neuralNetworkOutputCount,
          ]);
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

  Vehicle? vehicle;
  double vehicleOpacity;

  static const double friction = WorldSettings.trainingCarsFriction;
  static const double acceleration = WorldSettings.trainingCarsAcceleration;
  static const double steerAngle = WorldSettings.trainingCarsSteerAngle;
  bool damaged = false;

  late Sensor sensor;
  bool showSensor = false;

  late Controls controls;
  final ControlType controlType;

  NeuralNetwork? brain;
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
    Vehicle? vehicle,
    double? vehicleOpacity,
  }) {
    return Car(
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      controlType: controlType ?? this.controlType,
      speed: speed ?? this.speed,
      angle: angle ?? this.angle,
      vehicle: vehicle ?? this.vehicle,
      vehicleOpacity: vehicleOpacity ?? this.vehicleOpacity,
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
      List<double> outputs = NeuralNetwork.feedForward(offsets, brain!);

      if (useBrain) {
        controls.forward = outputs[0] > 0;
        controls.left = outputs[1] > 0;
        controls.right = outputs[2] > 0;
        controls.reverse = outputs[3] > 0;
      }
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
    canvas.save();

    canvas.translate(x, y);
    canvas.rotate(-angle);
    paintImage(
      canvas: canvas,
      rect: Rect.fromPoints(
        Offset(-width / 2, -height / 2),
        Offset(width / 2, height / 2),
      ),
      image: vehicle!.image!,
      fit: BoxFit.scaleDown,
      colorFilter: damaged
          ? const ColorFilter.mode(Colors.redAccent, BlendMode.srcIn)
          : null,
      opacity: damaged ? 0.2 : vehicleOpacity,
    );

    canvas.restore();

    if (controlType != ControlType.dummy && showSensor) {
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
