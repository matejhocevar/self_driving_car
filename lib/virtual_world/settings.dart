import 'package:flutter/material.dart';

class VirtualWorldSettings {
  // Viewport
  static const double viewportZoomStep = 0.1;
  static const double viewportZoomMin = 1;
  static const double viewportZoomMax = 5;

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

  // Graph Editor
  static Paint graphEditorSelectedPaint = Paint()
    ..color = Colors.yellow
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke;
  static Paint graphEditorHoveredPaint = Paint()
    ..color = Colors.yellow
    ..strokeWidth = 2
    ..style = PaintingStyle.fill;
  static const double graphEditorSelectedThreshold = 16;

  // Controls
  static const Size controlsSize = Size(400, 36);
  static const Color controlsBackgroundColor = Colors.black87;
  static const double controlsMargin = 16;
  static const Radius controlsRadius = Radius.circular(6);
}
