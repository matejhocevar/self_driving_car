import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../common/primitives/point.dart';
import '../../common/primitives/polygon.dart';
import '../../common/primitives/segment.dart';
import '../../utils/math.dart';
import '../graph.dart';
import '../markings/crossing.dart';
import '../markings/marking.dart';
import '../settings.dart';
import '../viewport.dart';
import '../world.dart';

class CrossingEditor extends StatefulWidget {
  const CrossingEditor({
    super.key,
    required this.world,
    required this.viewport,
  });

  final World world;
  final ViewPort viewport;

  @override
  State<CrossingEditor> createState() => _CrossingEditorState();
}

class _CrossingEditorState extends State<CrossingEditor> {
  late Graph graph;
  late ViewPort viewport;
  late List<Marking> markings;

  Point? mouse;
  Crossing? intent;

  bool isDragging = false;

  @override
  void initState() {
    super.initState();

    graph = widget.world.graph;
    viewport = widget.viewport;
    markings = widget.world.markings;
  }

  void _handleHover(PointerHoverEvent event) {
    mouse = viewport.getMouse(
      Point.fromOffset(event.localPosition),
      subtractDragOffset: true,
    );
    Segment? segment = getNearestSegment(
      mouse!,
      widget.world.graph.segments,
      threshold:
          VirtualWorldSettings.graphEditorSelectedThreshold * viewport.zoom,
    );

    if (segment != null) {
      final (projPoint, offset) = segment.projectPoint(mouse!);
      if (offset >= 0 && offset <= 1) {
        intent = Crossing(
          projPoint,
          segment.directionVector(),
          width: widget.world.roadWidth,
          height: widget.world.roadWidth / 2,
        );
      } else {
        intent = null;
      }
    } else {
      intent = null;
    }
    setState(() {});
  }

  void _handleTapDown(TapDownDetails tap) {
    if (intent != null) {
      markings.add(intent as Marking);
      intent = null;
      setState(() {});
    }
  }

  void _handleSecondaryTapDown(tap) {
    for (int i = 0; i < markings.length; i++) {
      Polygon p = markings[i].polygon;
      if (p.containsPoint(mouse!)) {
        markings.removeAt(i);
        setState(() {});
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: _handleHover,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onSecondaryTapDown: _handleSecondaryTapDown,
        child: CustomPaint(
          painter: CrossingEditorPainter(
            world: widget.world,
            viewport: widget.viewport,
            mouse: mouse,
            intent: intent,
          ),
        ),
      ),
    );
  }
}

class CrossingEditorPainter extends CustomPainter {
  const CrossingEditorPainter({
    required this.world,
    required this.viewport,
    this.mouse,
    this.intent,
  });

  final World world;
  final ViewPort viewport;
  final Point? mouse;
  final Crossing? intent;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    canvas.translate(viewport.center.x, viewport.center.y);
    canvas.scale(1 / viewport.zoom, 1 / viewport.zoom);
    Point offset = viewport.getOffset();
    canvas.translate(offset.x, offset.y);

    world.paint(canvas, size);
    world.graph.paint(canvas, size);

    intent?.paint(canvas, size);

    intent?.paint(canvas, size);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CrossingEditorPainter oldDelegate) => true;
}
