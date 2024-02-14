import 'dart:convert';
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../common/primitives/envelope.dart';
import '../common/primitives/point.dart';
import '../common/primitives/polygon.dart';
import '../common/primitives/segment.dart';
import '../common/traffic_light_system.dart';
import '../utils/math.dart';
import 'graph.dart';
import 'markings/marking.dart';
import 'markings/traffic_light.dart';
import 'settings.dart';
import 'street_furniture/building.dart';
import 'street_furniture/street_furniture.dart';
import 'street_furniture/tree.dart';
import 'viewport.dart';

class World extends CustomPainter {
  World({
    required this.graph,
    required this.viewport,
    double? roadWidth,
    int? roadRoundness,
    double? buildingWidth,
    double? buildingMinLength,
    double? spacing,
    double? treeSize,
    int? treeTryCount,
    this.graphHash,
  }) {
    this.roadWidth = roadWidth ?? VirtualWorldSettings.roadWidth;
    this.roadRoundness = roadRoundness ?? VirtualWorldSettings.roadRoundness;
    this.buildingWidth = buildingWidth ?? VirtualWorldSettings.buildingWidth;
    this.buildingMinLength =
        buildingMinLength ?? VirtualWorldSettings.buildingMinLength;
    this.spacing = spacing ?? VirtualWorldSettings.buildingSpacing;
    this.treeSize = treeSize ?? VirtualWorldSettings.treeSize;
    this.treeTryCount = treeTryCount ?? VirtualWorldSettings.treeTryCount;
  }

  final Graph graph;
  final ViewPort viewport;
  String? graphHash;
  late final double roadWidth;
  late final int roadRoundness;

  late final double buildingWidth;
  late final double buildingMinLength;
  late final double spacing;
  late final double treeSize;
  late final int treeTryCount;

  List<Envelope> envelopes = List.empty(growable: true);
  List<Segment> roadBorders = List.empty(growable: true);
  List<Segment> laneGuides = List.empty(growable: true);
  List<Marking> markings = List.empty(growable: true);

  List<Building> buildings = List.empty(growable: true);
  List<Tree> trees = List.empty(growable: true);

  void dispose() {
    graph.dispose();
    markings.length = 0;
  }

  void generate() {
    envelopes.length = 0;
    for (Segment s in graph.segments) {
      envelopes.add(Envelope(s, width: roadWidth, roundness: roadRoundness));
    }

    roadBorders = Polygon.union(envelopes.map((e) => e.polygon).toList());

    buildings = _generateBuildings();
    trees = _generateTrees();

    laneGuides.length = 0;
    laneGuides = _generateLaneGuides();
  }

  List<Building> _generateBuildings() {
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

    return bases
        .map(
          (b) => Building(
            b,
            height: VirtualWorldSettings.buildingHeight,
            sideColor: VirtualWorldSettings.buildingSideColor,
            sideBorderColor: VirtualWorldSettings.buildingSideBorderColor,
            roofColor: VirtualWorldSettings.buildingRoofColor,
            roofBorderColor: VirtualWorldSettings.buildingRoofBorderColor,
          ),
        )
        .toList();
  }

  List<Tree> _generateTrees() {
    List<Tree> trees = [];

    final points = [
      ...roadBorders.map((s) => [s.p1, s.p2]).expand((e) => e).toList(),
      ...buildings.map((b) => b.base.points).expand((e) => e).toList(),
    ];

    if (points.isNotEmpty) {
      final left = points.map((p) => p.x).reduce(math.min);
      final right = points.map((p) => p.x).reduce(math.max);
      final top = points.map((p) => p.y).reduce(math.min);
      final bottom = points.map((p) => p.y).reduce(math.max);

      List<Polygon> illegalPolygons = [
        ...buildings.map((b) => b.base),
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
            if (distance(tree.center, p) < treeSize) {
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
          trees.add(
            Tree(
              p,
              treeSize / 2,
              height: VirtualWorldSettings.treeHeight,
              layers: VirtualWorldSettings.treeLayers,
            ),
          );
          tryCount = 0;
        }

        tryCount++;
      }
    }

    return trees;
  }

  List<Segment> _generateLaneGuides() {
    List<Envelope> tmpEnvelopes = [];
    for (Segment s in graph.segments) {
      tmpEnvelopes.add(
        Envelope(
          s,
          width: roadWidth / 2,
          roundness: roadRoundness,
        ),
      );
    }

    return Polygon.union(tmpEnvelopes.map((e) => e.polygon).toList());
  }

  void updateLights(int tick) {
    List<TrafficLight> lights = markings.whereType<TrafficLight>().toList();

    // Group traffic lights by nearby system
    List<TrafficLightSystem> trafficLightSystems = [];
    for (TrafficLight light in lights) {
      Point? point = getNearestPoint(light.center, getIntersections());

      if (point != null) {
        TrafficLightSystem? system =
            trafficLightSystems.firstWhereOrNull((s) => s.center == point);
        if (system == null) {
          system = TrafficLightSystem(
            point,
            lights: [light],
            greenDuration: VirtualWorldSettings.trafficLightsGreenDuration,
            yellowDuration: VirtualWorldSettings.trafficLightsYellowDuration,
            redDuration: VirtualWorldSettings.trafficLightsRedDuration,
          );
          trafficLightSystems.add(system);
        } else {
          system.lights.add(light);
        }
      }
    }

    for (TrafficLightSystem s in trafficLightSystems) {
      // If system is not working display blinking yellow lights
      if (s.lightsNotWorking) {
        for (TrafficLight light in s.lights) {
          light.state = light.state == TrafficLightState.yellow
              ? TrafficLightState.off
              : TrafficLightState.yellow;
        }
        continue;
      }

      // Determinate current state
      int systemTick = tick % s.ticks;
      int greenYellowIndex = systemTick ~/ (s.greenDuration + s.yellowDuration);
      TrafficLightState greenAndYellowState =
          systemTick % (s.greenDuration + s.yellowDuration) < s.greenDuration
              ? TrafficLightState.green
              : TrafficLightState.yellow;

      // Assign states to all lights in the system
      for (int i = 0; i < s.lights.length; i++) {
        if (i == greenYellowIndex) {
          s.lights[i].state = greenAndYellowState;
        } else {
          s.lights[i].state = TrafficLightState.red;
        }
      }
    }
  }

  List<Point> getIntersections() {
    List<Point> intersections = [];

    for (Point p in graph.points) {
      int degree = 0;
      for (Segment s in graph.segments) {
        if (s.includes(p)) {
          degree++;
        }
      }

      if (degree > 2) {
        intersections.add(p);
      }
    }

    return intersections;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (graph.hash != graphHash) {
      generate();
      graphHash = graph.hash;
    }

    final viewPoint = scale(viewport.getOffset(), -1);

    // Road envelope
    for (Envelope e in envelopes) {
      e.paint(
        canvas,
        size,
        fill: VirtualWorldSettings.roadColor,
        lineWidth: VirtualWorldSettings.roadMargin,
      );
    }

    // Markings
    for (Marking m in markings) {
      m.paint(canvas, size);
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

    List<StreetFurniture> streetFurniture = [...buildings, ...trees];
    streetFurniture.sort((a, b) => b.base
        .distanceToPoint(viewPoint)
        .compareTo(a.base.distanceToPoint(viewPoint)));

    // Buildings & Trees
    for (StreetFurniture sf in streetFurniture) {
      sf.paint(canvas, size, viewPoint: viewPoint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  @override
  String toString() {
    Map<String, dynamic> json = {
      'graph': graph.toString(),
      'graphHash': graphHash,
      'envelopes': envelopes.map((e) => e.toString()).toList(),
      'road_borders': roadBorders.map((r) => r.toJSON()).toList(),
      'lane_guides': laneGuides.map((l) => l.toJSON()).toList(),
      'buildings': buildings.map((b) => b.toString()).toList(),
      'trees': trees.map((t) => t.toString()).toList(),
      'markings': markings.map((m) => m.toString()).toList(),
    };
    return jsonEncode(json);
  }

  static World fromString(String? str, {required ViewPort viewport}) {
    try {
      if (str == null || str.isEmpty) {
        throw const FormatException('Unable to parse the model from cache.');
      }

      final json = jsonDecode(str);

      Graph graph = Graph.fromString(json['graph']);
      World world = World(
        graph: graph,
        viewport: viewport,
        graphHash: graph.hash,
      );

      // Envelopes
      List<Envelope> envelopes = (json['envelopes'] as List<dynamic>)
          .map((e) => Envelope.fromString(e))
          .toList();

      // Road borders
      List<Segment> roadBorders = (json['road_borders'] as List<dynamic>)
          .map((r) => Segment.load(r))
          .toList();

      // Lane guides
      List<Segment> laneGuides = (json['lane_guides'] as List<dynamic>)
          .map((l) => Segment.load(l))
          .toList();

      // Buildings
      List<Building> buildings = (json['buildings'] as List<dynamic>)
          .map((b) => Building.fromString(b))
          .toList();

      // Trees
      List<Tree> trees = (json['trees'] as List<dynamic>)
          .map((t) => Tree.fromString(t))
          .toList();

      // Markings
      List<Marking> markings = (json['markings'] as List<dynamic>)
          .map((m) => Marking.fromString(m))
          .toList();

      return world
        ..envelopes = envelopes
        ..roadBorders = roadBorders
        ..laneGuides = laneGuides
        ..buildings = buildings
        ..trees = trees
        ..markings = markings;
    } catch (e, stackTrace) {
      print(e);
      print(stackTrace);
      print('Creating a new instance...');
    }

    return World(graph: Graph(), viewport: viewport);
  }
}
