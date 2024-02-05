import 'dart:math' as math;

import 'package:flutter/material.dart';

void drawDashedLine(
  Canvas canvas,
  Offset p1,
  Offset p2,
  Paint paint, {
  int dashWidth = 20,
  int dashSpace = 20,
}) {
  var dx = p2.dx - p1.dx;
  var dy = p2.dy - p1.dy;
  final magnitude = math.sqrt(dx * dx + dy * dy);
  final steps = magnitude ~/ (dashWidth + dashSpace);
  dx = dx / magnitude;
  dy = dy / magnitude;
  var startX = p1.dx;
  var startY = p1.dy;

  for (int i = 0; i < steps; i++) {
    canvas.drawLine(
      Offset(startX, startY),
      Offset(startX + dx * dashWidth, startY + dy * dashWidth),
      paint,
    );
    startX += dx * (dashWidth + dashSpace);
    startY += dy * (dashWidth + dashSpace);
  }
}
