import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../infinity_road/settings.dart';
import '../neural_network/neural_network.dart';
import '../utils/math.dart';
import 'controls.dart';
import 'primitives/position.dart';
import 'sensor.dart';
import 'vehicle.dart';

class Car extends CustomPainter {
  Car({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.maxSpeed = 3,
    double? friction,
    double? acceleration,
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
        rayCount: InfinityRoadSettings.sensorRayCount,
        rayLength: InfinityRoadSettings.sensorRayLength,
        raySpread: InfinityRoadSettings.sensorRaySpread,
      );
      brain = brain ??
          NeuralNetwork(neuronCounts: [
            sensor.rayCount,
            InfinityRoadSettings.neuralNetworkLevel1Count,
            InfinityRoadSettings.neuralNetworkOutputCount,
          ]);
    }

    polygon = _createPolygon();
    controls = Controls(type: controlType);

    this.friction = friction ?? InfinityRoadSettings.trainingCarsFriction;
    this.acceleration =
        acceleration ?? InfinityRoadSettings.trainingCarsAcceleration;
  }

  double x;
  double y;
  double width;
  double height;
  double speed;
  double angle;
  double maxSpeed;
  late double friction;
  late double acceleration;

  Vehicle? vehicle;
  double vehicleOpacity;

  static const double steerAngle = InfinityRoadSettings.trainingCarsSteerAngle;
  bool damaged = false;

  late Sensor sensor;
  bool showSensor = false;

  late Controls controls;
  final ControlType controlType;

  NeuralNetwork? brain;
  bool useBrain = false;
  double fitness = 0;

  late List<Offset> polygon;

  void update(List<List<Offset>> roadBorders, List<Car> traffic) {
    if (!damaged) {
      _move();
      fitness += speed;
      polygon = _createPolygon();
      damaged = _assessDamage(roadBorders, traffic);
    }

    if (controlType != ControlType.dummy) {
      sensor.update(roadBorders, traffic);

      // Set distance sensors
      List<double> offsets = sensor.readings
          .map((Position? p) => p?.offset == null ? 0.0 : 1 - p!.offset)
          .toList();
      // Set normalized speed
      offsets.add(speed / maxSpeed);

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
      speed += acceleration;
    }
    if (controls.reverse) {
      speed -= acceleration;
    }

    if (speed > maxSpeed) {
      speed = maxSpeed;
    }

    if (speed < -maxSpeed / 2) {
      speed = -maxSpeed / 2;
    }

    if (speed > 0) {
      speed -= friction;
    }

    if (speed < 0) {
      speed += friction;
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

  void updateFromString(String str) {
    final data = jsonDecode(str);

    brain = NeuralNetwork.fromString(json.encode(data['brain']));
    maxSpeed = data['maxSpeed'];
    friction = data['friction'];
    acceleration = data['acceleration'];
    sensor = Sensor.fromJson(this, data['sensor']);
  }

  @override
  String toString() {
    return 'Car(x: $x, y: $y, width: $width, height: $height)';
  }
}
