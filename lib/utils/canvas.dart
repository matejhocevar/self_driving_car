import 'dart:math' as math;

import 'package:flutter/material.dart';

void drawDashedLine(
  Canvas canvas,
  Offset p1,
  Offset p2,
  Paint paint, {
  int dashWidth = 20,
  int dashSpace = 20,
  bool showPartialLines = false,
}) {
  var dx = p2.dx - p1.dx;
  var dy = p2.dy - p1.dy;
  final magnitude = math.sqrt(dx * dx + dy * dy);
  final steps = magnitude ~/ (dashWidth + dashSpace);
  final finalStepDiff = (magnitude / (dashWidth + dashSpace)) - steps;
  dx = dx / magnitude;
  dy = dy / magnitude;
  var startX = p1.dx;
  var startY = p1.dy;

  final double eps = showPartialLines ? 0.001 : 0;
  for (int i = 0; i < steps + eps; i++) {
    double endX = startX + dx * dashWidth;
    double endY = startY + dy * dashWidth;
    if (showPartialLines && i == steps) {
      endX = startX + (dx * dashWidth * finalStepDiff);
      endY = startY + (dy * dashWidth * finalStepDiff);
    }
    canvas.drawLine(
      Offset(startX, startY),
      Offset(endX, endY),
      paint,
    );
    startX += dx * (dashWidth + dashSpace);
    startY += dy * (dashWidth + dashSpace);
  }
}

Color getRandomColor() {
  double hue = 100 + math.Random().nextDouble() * 260;
  return HSLColor.fromAHSL(1, hue, 1, 0.6).toColor();
}
