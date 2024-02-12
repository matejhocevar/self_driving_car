import 'package:flutter/material.dart';

import '../common/primitives/envelope.dart';
import '../common/primitives/polygon.dart';
import '../common/primitives/segment.dart';
import 'graph.dart';
import 'settings.dart';

class World extends CustomPainter {
  World({
    required this.graph,
    this.roadWidth = 100,
    this.roadRoundness = 3,
  }) {
    generate();
  }

  final Graph graph;
  final double roadWidth;
  final int roadRoundness;
  List<Envelope> envelopes = List.empty(growable: true);
  List<Segment> roadBorders = List.empty(growable: true);

  void generate() {
    envelopes.length = 0;
    for (Segment s in graph.segments) {
      envelopes.add(Envelope(s, width: roadWidth, roundness: roadRoundness));
    }

    roadBorders = Polygon.union(envelopes.map((e) => e.polygon).toList());
  }

  @override
  void paint(Canvas canvas, Size size) {
    generate();

    // Road envelope
    for (Envelope e in envelopes) {
      e.paint(
        canvas,
        size,
        fill: VirtualWorldSettings.roadColor,
        lineWidth: VirtualWorldSettings.roadMargin,
      );
    }

    // Road lane
    for (Segment s in graph.segments) {
      s.paint(
        canvas,
        size,
        color: Colors.white,
        dash: VirtualWorldSettings.roadLineDash,
      );
    }

    // Road border
    for (Segment b in roadBorders) {
      b.paint(
        canvas,
        size,
        color: Colors.white,
        width: VirtualWorldSettings.roadBorderWidth,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
