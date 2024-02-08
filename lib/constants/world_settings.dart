import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/vehicle.dart';
import 'vehicles.dart';

class WorldSettings {
  WorldSettings._();

  // Road
  static const Size roadSize = Size(200, double.infinity);
  static const int roadLaneCount = 3;
  static const double roadInfinity = 10000;

  // Training car
  static const int trainingCarsN = 500;
  static Vehicle trainingCarsModel = vehicles[1];
  static const double trainingCarsStartingY = 100;
  static const double trainingCarsOpacity = 0.2;
  static const double trainingCarsFriction = 0.05;
  static const double trainingCarsAcceleration = 0.2;
  static const double trainingCarsSteerAngle = 0.03;

  // Sensor
  static const bool sensorShowRays = true;
  static const int sensorRayCount = 5;
  static const double sensorRayLength = 150;
  static const double sensorRaySpread = math.pi / 2;

  // Traffic
  static const List<({int lane, double y})> trafficLocations = [
    (lane: 1, y: -100),
    (lane: 0, y: -300),
    (lane: 2, y: -300),
    (lane: 0, y: -500),
    (lane: 1, y: -500),
    (lane: 1, y: -700),
    (lane: 2, y: -700),
    (lane: 2, y: -800),
    (lane: 1, y: -900),
    (lane: 0, y: -1100),
    (lane: 0, y: -1300),
    (lane: 2, y: -1300),
    (lane: 1, y: -1450),
    (lane: 0, y: -1600),
    (lane: 2, y: -1600),
    (lane: 1, y: -1800),
  ];

  // Neural Network
  static const int neuralNetworkLevel1Count = 6;
  static const int neuralNetworkOutputCount = 4;
  static const double neuralNetworkMutation = 0.1;

  // Visualisation
  static const Color visualisationBackgroundColor = Colors.black87;
  static const double visualisationMargin = 16;
  static const Radius visualisationRadius = Radius.circular(6);
  static const Size visualisationNetworkGraphSize = Size(250, 250);
  static const Size visualisationToolbarSize = Size(250, 36);
  static const Size visualisationProgressBarSize = Size(250, 4);
}
