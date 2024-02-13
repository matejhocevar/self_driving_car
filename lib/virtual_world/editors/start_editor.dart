import 'package:flutter/material.dart';

import '../../common/primitives/point.dart';
import '../../common/primitives/segment.dart';
import '../../common/vehicle.dart';
import '../markings/marking.dart';
import '../markings/start.dart';
import '../viewport.dart';
import '../world.dart';
import 'marking_editor.dart';

class StartEditor extends MarkingEditor {
  const StartEditor({
    Key? key,
    required World world,
    required ViewPort viewport,
    required List<Segment> targetSegments,
    required this.vehicle,
  }) : super(
          key: key,
          world: world,
          viewport: viewport,
          targetSegments: targetSegments,
        );

  final Vehicle vehicle;

  @override
  Marking createMarking(Point position, Segment segment) {
    return Start(
      position,
      segment.directionVector(),
      vehicle,
      width: world.roadWidth / 2,
      height: world.roadWidth / 2,
    );
  }
}
