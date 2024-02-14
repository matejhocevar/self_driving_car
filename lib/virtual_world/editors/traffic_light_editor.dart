import 'package:flutter/material.dart';

import '../../common/primitives/point.dart';
import '../../common/primitives/segment.dart';
import '../markings/marking.dart';
import '../markings/traffic_light.dart';
import '../world.dart';
import 'marking_editor.dart';

class TrafficLightEditor extends MarkingEditor {
  const TrafficLightEditor({
    Key? key,
    required World world,
    required List<Segment> targetSegments,
  }) : super(
          key: key,
          world: world,
          targetSegments: targetSegments,
        );

  @override
  Marking createMarking(Point position, Segment segment) {
    return TrafficLight(
      position,
      segment.directionVector(),
      width: world.roadWidth / 2,
      height: world.roadWidth / 2,
    );
  }
}
