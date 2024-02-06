import 'package:flutter/material.dart';

import '../network/level.dart';
import '../network/network.dart';
import '../utils/math.dart';

class VisualiserPainter extends CustomPainter {
  const VisualiserPainter({
    required this.network,
  });

  final NeuralNetwork network;

  final double margin = 32;
  static const Color backgroundColor = Colors.black87;

  @override
  void paint(Canvas canvas, Size size) {
    double top = margin;
    double left = margin;
    double width = size.width - margin * 2;
    double height = size.height - margin * 2;

    const borderRadius = Radius.circular(6);
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        0,
        0,
        size.width,
        size.height,
        topLeft: borderRadius,
        topRight: borderRadius,
        bottomLeft: borderRadius,
        bottomRight: borderRadius,
      ),
      Paint()..color = VisualiserPainter.backgroundColor,
    );

    double levelHeight = height / network.levels.length;
    for (int i = network.levels.length - 1; i >= 0; i--) {
      double levelTop = top +
          lerp(
            height - levelHeight,
            0,
            network.levels.length == 1 ? 0.5 : i / (network.levels.length - 1),
          );

      _paintLevel(
        canvas,
        network.levels[i],
        top: levelTop,
        left: left,
        width: width,
        height: levelHeight,
        labels: i == network.levels.length - 1
            ? ["\u2191", "\u2190", "\u2192", "\u2193"]
            : [],
      );
    }
  }

  void _paintLevel(
    Canvas canvas,
    Level level, {
    double top = 0,
    double left = 0,
    double width = 0,
    double height = 0,
    List<String> labels = const [],
  }) {
    double right = left + width;
    double bottom = top + height;
    double nodeRadius = 18;

    var inputs = level.inputs;
    var outputs = level.outputs;

    // Draw connections
    for (int i = 0; i < inputs.length; i++) {
      for (int j = 0; j < outputs.length; j++) {
        var start = Offset(
          _getNodeX(nodes: inputs, index: i, left: left, right: right),
          bottom,
        );
        var end = Offset(
          _getNodeX(nodes: outputs, index: j, left: left, right: right),
          top,
        );

        canvas.drawLine(
          start,
          end,
          Paint()
            ..color = level.weights[i][j].toRGBA()
            ..strokeWidth = 2,
        );
      }
    }

    // Draw inputs
    for (int i = 0; i < inputs.length; i++) {
      double x = _getNodeX(
        nodes: inputs,
        index: i,
        left: left,
        right: right,
      );

      canvas.drawCircle(
        Offset(x, bottom),
        nodeRadius,
        Paint()..color = VisualiserPainter.backgroundColor,
      );

      canvas.drawCircle(
        Offset(x, bottom),
        nodeRadius * 0.6,
        Paint()..color = inputs[i].toRGBA(),
      );
    }

    // Draw outputs
    for (int i = 0; i < outputs.length; i++) {
      double x = _getNodeX(
        nodes: outputs,
        index: i,
        left: left,
        right: right,
      );

      canvas.drawCircle(
        Offset(x, top),
        nodeRadius,
        Paint()
          ..color = VisualiserPainter.backgroundColor
          ..strokeWidth = 2,
      );

      canvas.drawCircle(
        Offset(x, top),
        nodeRadius * 0.8,
        Paint()
          ..color = outputs[i].toRGBA()
          ..strokeWidth = 2,
      );

      canvas.drawCircle(
        Offset(x, top),
        nodeRadius,
        Paint()
          ..color = level.biases[i].toRGBA()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      if (labels.isNotEmpty) {
        TextSpan span = TextSpan(
          style: const TextStyle(color: Colors.green, fontSize: 24),
          text: labels[i],
        );
        TextPainter tp = TextPainter(
          text: span,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );
        tp.layout();
        tp.paint(canvas, Offset(x - 10, top - 14));
      }
    }
  }

  double _getNodeX({
    required List nodes,
    required int index,
    required double left,
    required double right,
  }) {
    return lerp(
      left,
      right,
      nodes.length == 1 ? 0.5 : index / (nodes.length - 1),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
