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

  // Trees
  static const double treeSize = 160;
  static const int treeTryCount = 100;

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
  static const Size controlsSize = Size(250, 36);
  static const Color controlsBackgroundColor = Colors.black87;
  static const double controlsMargin = 16;
  static const Radius controlsRadius = Radius.circular(6);
}
