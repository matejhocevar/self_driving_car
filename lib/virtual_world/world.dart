import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../common/primitives/envelope.dart';
import '../common/primitives/point.dart';
import '../common/primitives/polygon.dart';
import '../common/primitives/segment.dart';
import '../utils/math.dart';
import 'graph.dart';
import 'settings.dart';

class World extends CustomPainter {
  World({
    required this.graph,
    this.roadWidth = 100,
    this.roadRoundness = 3,
    this.buildingWidth = 150,
    this.buildingMinLength = 150,
    this.spacing = 50,
    this.treeSize = 160,
    this.treeTryCount = 100,
  }) {
    generate();
  }

  final Graph graph;
  String? graphHash;
  final double roadWidth;
  final int roadRoundness;

  final double buildingWidth;
  final double buildingMinLength;
  final double spacing;
  final double treeSize;
  final int treeTryCount;

  List<Envelope> envelopes = List.empty(growable: true);
  List<Segment> roadBorders = List.empty(growable: true);

  List<Polygon> buildings = List.empty(growable: true);
  List<Point> trees = List.empty(growable: true);

  void generate() {
    envelopes.length = 0;
    for (Segment s in graph.segments) {
      envelopes.add(Envelope(s, width: roadWidth, roundness: roadRoundness));
    }

    roadBorders = Polygon.union(envelopes.map((e) => e.polygon).toList());

    buildings = _generateBuildings();
    trees = _generateTrees();
  }

  List<Polygon> _generateBuildings() {
    List<Envelope> tmpEnvelopes = [];
    for (Segment s in graph.segments) {
      tmpEnvelopes.add(
        Envelope(
          s,
          width: roadWidth + buildingWidth + spacing * 2,
          roundness: roadRoundness,
        ),
      );
    }

    // Calculate guides for building placement
    final guides = Polygon.union(tmpEnvelopes.map((e) => e.polygon).toList());
    for (int i = 0; i < guides.length; i++) {
      final s = guides[i];
      if (s.length() < buildingMinLength) {
        guides.removeAt(i);
        i--;
      }
    }

    // Calculate supports for the building
    List<Segment> supports = [];
    for (Segment s in guides) {
      double length = s.length() + spacing;
      int buildingCount = length ~/ (buildingMinLength + spacing);
      double buildingLength = length / buildingCount - spacing;

      final Point dir = s.directionVector();

      Point q1 = s.p1;
      Point q2 = add(q1, scale(dir, buildingLength));
      supports.add(Segment(q1, q2));

      for (int i = 2; i < buildingCount; i++) {
        q1 = add(q2, scale(dir, spacing));
        q2 = add(q1, scale(dir, buildingLength));
        supports.add(Segment(q1, q2));
      }
    }

    // Calculate building bases
    List<Polygon> bases = [];
    for (Segment s in supports) {
      bases.add(Envelope(s, width: buildingWidth).polygon);
    }

    // Remove overlapping buildings
    const eps = 0.001;
    for (int i = 0; i < bases.length - 1; i++) {
      for (int j = i + 1; j < bases.length; j++) {
        if (bases[i].intersectsPolygon(bases[j]) ||
            bases[i].distanceToPolygon(bases[j]) < spacing - eps) {
          bases.removeAt(j);
          j--;
        }
      }
    }

    return bases;
  }

  List<Point> _generateTrees() {
    List<Point> trees = [];

    final points = [
      ...roadBorders.map((s) => [s.p1, s.p2]).expand((e) => e).toList(),
      ...buildings.map((b) => b.points).expand((e) => e).toList(),
    ];

    if (points.isNotEmpty) {
      final left = points.map((p) => p.x).reduce(math.min);
      final right = points.map((p) => p.x).reduce(math.max);
      final top = points.map((p) => p.y).reduce(math.min);
      final bottom = points.map((p) => p.y).reduce(math.max);

      List<Polygon> illegalPolygons = [
        ...buildings,
        ...envelopes.map((e) => e.polygon),
      ];

      int tryCount = 0;
      while (tryCount < treeTryCount) {
        Point p = Point(
          lerp(left, right, math.Random().nextDouble()),
          lerp(bottom, top, math.Random().nextDouble()),
        );

        // Check for tree inside or nearby buildings / road
        bool keep = true;
        for (Polygon polygon in illegalPolygons) {
          if (polygon.containsPoint(p) ||
              polygon.distanceToPoint(p) < treeSize / 2) {
            keep = false;
            break;
          }
        }

        // Check if it overlap existing trees
        if (keep) {
          for (var tree in trees) {
            if (distance(tree, p) < treeSize) {
              keep = false;
              break;
            }
          }
        }

        // Avoiding trees in the middle of nowhere
        if (keep) {
          bool closeToSomething = false;
          for (Polygon polygon in illegalPolygons) {
            if (polygon.distanceToPoint(p) < treeSize * 2) {
              closeToSomething = true;
              break;
            }
          }
          keep = closeToSomething;
        }

        if (keep) {
          trees.add(p);
          tryCount = 0;
        }

        tryCount++;
      }
    }

    return trees;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (graph.hash != graphHash) {
      generate();
      graphHash = graph.hash;
    }

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

    // Buildings
    for (Polygon b in buildings) {
      b.paint(
        canvas,
        size,
        fill: Colors.blue.withOpacity(0.3),
        stroke: Colors.blue,
      );
    }

    // Trees
    for (Point p in trees) {
      p.paint(
        canvas,
        size,
        radius: treeSize / 2,
        color: Colors.black87.withOpacity(0.5),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
