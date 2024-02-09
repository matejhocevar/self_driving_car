import 'package:flutter/material.dart';

class VirtualWorldSettings {
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
