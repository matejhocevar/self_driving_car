import 'package:flutter/material.dart';

import '../../common/primitives/point.dart';
import '../../common/primitives/segment.dart';
import '../markings/marking.dart';
import '../markings/yield.dart';
import '../viewport.dart';
import '../world.dart';
import 'marking_editor.dart';

class YieldEditor extends MarkingEditor {
  const YieldEditor({
    Key? key,
    required World world,
    required ViewPort viewport,
    required List<Segment> targetSegments,
  }) : super(
          key: key,
          world: world,
          viewport: viewport,
          targetSegments: targetSegments,
        );

  @override
  Marking createMarking(Point position, Segment segment) {
    return Yield(
      position,
      segment.directionVector(),
      width: world.roadWidth / 2,
      height: world.roadWidth / 2,
    );
  }
}
