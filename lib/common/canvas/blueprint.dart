import 'package:flutter/material.dart';

import '../../virtual_world/settings.dart';
import '../../virtual_world/viewport.dart';

class BlueprintPainter extends CustomPainter {
  final Paint gridPaint = Paint()
    ..color = Colors.white
    ..strokeWidth = 0.55;

  final Paint surfacePaint = Paint()
    ..color = VirtualWorldSettings.editorBlueprintColor;

  final double gridSize = VirtualWorldSettings.editorBlueprintGridSize;
  final double bufferFactor = VirtualWorldSettings.editorBlueprintBufferFactor;

  @override
  void paint(Canvas canvas, Size size, {ViewPort? viewport}) {
    viewport ??= ViewPort(width: size.width, height: size.height);

    canvas.drawPaint(surfacePaint);

    canvas.save();
    final double scaledCellSize = gridSize * 1 / viewport.zoom;

    final offset = viewport.getOffset();
    final startX =
        ((offset.x / viewport.zoom) - (size.width * bufferFactor)).floor() *
            scaledCellSize;
    final startY =
        ((offset.y / viewport.zoom) - (size.height * bufferFactor)).floor() *
            scaledCellSize;

    final endX =
        ((offset.x / viewport.zoom) + (size.width * (1 + bufferFactor)))
                .ceil() *
            scaledCellSize;
    final endY =
        ((offset.y / viewport.zoom) + (size.height * (1 + bufferFactor)))
                .ceil() *
            scaledCellSize;

    // Draw vertical gridlines
    for (double x = startX; x <= endX; x += scaledCellSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // Draw horizontal gridlines
    for (double y = startY; y <= endY; y += scaledCellSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
