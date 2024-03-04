import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../common/constants/vehicles.dart';
import '../common/controls.dart';
import '../common/primitives/point.dart';
import '../common/vehicle.dart';

class VirtualWorldSettings {
  VirtualWorldSettings._();

  // Viewport
  static const double viewportZoomStep = 0.1;
  static const double viewportZoomMin = 1;
  static const double viewportZoomMax = 5;
  static const double viewportRenderRadius = 1000;

  // Environment
  static const Color surfaceColor = Color(0xff37ae0f);

  // Road
  static const double roadWidth = 100;
  static const double roadMargin = 15;
  static const int roadRoundness = 10;
  static const List<int> roadLineDash = [10, 10];
  static const double roadBorderWidth = 4;
  static const Color roadColor = Color(0xffbbbbbb);

  // Building
  static const double buildingWidth = 150;
  static const double buildingMinLength = 150;
  static const double buildingSpacing = 50;
  static const double buildingHeight = 120;
  static const Color buildingSideColor = Color(0xffffffff);
  static const Color buildingSideBorderColor = Color(0xaaaaaaaa);
  static const Color buildingRoofColor = Color(0xffd44444);
  static const Color buildingRoofBorderColor = Color(0xffc44444);

  // Trees
  static const double treeSize = 160;
  static const int treeTryCount = 100;
  static const double treeHeight = 200;
  static const int treeLayers = 7;

  // Rivers
  static const double riverWidth = 100;
  static const double riverMargin = 15;
  static const int riverRoundness = 10;
  static const Color riverColor = Color(0xff4682B4);

  // Sea and lakes
  static const double seaAndLakesMargin = 15;
  static const Color seaAndLakesColor = Color(0xff4682B4);

  // Editors
  static const Color editorBlueprintColor = Color(0xff2168e8);
  static const double editorBlueprintGridSize = 100;
  static const double editorBlueprintBufferFactor = 3;
  static Paint editorSelectedPaint = Paint()
    ..color = Colors.yellow
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke;
  static Paint editorHoveredPaint = Paint()
    ..color = Colors.yellow
    ..strokeWidth = 2
    ..style = PaintingStyle.fill;
  static const double editorSelectedThreshold = 16;

  // Traffic lights
  static const int trafficLightsGreenDuration = 2;
  static const int trafficLightsYellowDuration = 1;
  static const int trafficLightsRedDuration = 1;

  // Controls
  static const Size controlsSize = Size(36, 580);
  static const Color controlsBackgroundColor = Colors.black87;
  static const double controlsMargin = 16;
  static const Radius controlsRadius = Radius.circular(6);

  // Training car
  static const int trainingCarsN = 1;
  static const ControlType controlType = ControlType.AI;
  static Vehicle trainingCarsModel = vehicles[1];
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
  static const List<({int lane, Point location})> trafficLocations = [];

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

  // Minimap
  static const double minimapRadius = 250;
  static const Color minimapBorderColor = Colors.black87;
  static const double minimapBorderWidth = 10;
  static const Color minimapRoadColor = Colors.black87;
  static const double minimapRoadWidthFactor = 4;
  static const Color minimapCarIndicatorColor = Colors.blue;
  static const bool minimapCarIndicatorOutline = true;
  static const double minimapCarIndicatorRadius = 6;
  static const double minimapScalerDefault = 0.05;
  static const double minimapScalerIncreaseFactor = 0.5;
  static const double minimapScalerDecreaseFactor = 2;
}
