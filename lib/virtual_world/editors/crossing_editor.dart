import 'package:flutter/material.dart';

import '../../common/primitives/point.dart';
import '../../common/primitives/segment.dart';
import '../markings/crossing.dart';
import '../markings/marking.dart';
import '../world.dart';
import 'marking_editor.dart';

class CrossingEditor extends MarkingEditor {
  const CrossingEditor({
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
    return Crossing(
      position,
      segment.directionVector(),
      width: world.roadWidth,
      height: world.roadWidth / 2,
    );
  }
}
