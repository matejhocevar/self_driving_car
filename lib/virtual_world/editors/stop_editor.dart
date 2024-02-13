import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../common/primitives/point.dart';
import '../../common/primitives/polygon.dart';
import '../../common/primitives/segment.dart';
import '../../utils/math.dart';
import '../graph.dart';
import '../markings/marking.dart';
import '../markings/stop.dart';
import '../settings.dart';
import '../viewport.dart';
import '../world.dart';

class StopEditor extends StatefulWidget {
  const StopEditor({
    super.key,
    required this.world,
    required this.viewport,
  });

  final World world;
  final ViewPort viewport;

  @override
  State<StopEditor> createState() => _StopEditorState();
}

class _StopEditorState extends State<StopEditor> {
  late Graph graph;
  late ViewPort viewport;
  late List<Marking> markings;

  Point? mouse;
  Stop? intent;

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
      widget.world.laneGuides,
      threshold:
          VirtualWorldSettings.graphEditorSelectedThreshold * viewport.zoom,
    );

    if (segment != null) {
      final (projPoint, offset) = segment.projectPoint(mouse!);
      if (offset >= 0 && offset <= 1) {
        intent = Stop(
          projPoint,
          segment.directionVector(),
          width: widget.world.roadWidth / 2,
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
      Polygon p = (markings[i] as Stop).polygon;
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
          painter: StopEditorPainter(
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

class StopEditorPainter extends CustomPainter {
  const StopEditorPainter({
    required this.world,
    required this.viewport,
    this.mouse,
    this.intent,
  });

  final World world;
  final ViewPort viewport;
  final Point? mouse;
  final Stop? intent;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPaint(Paint()..color = Colors.green);

    canvas.save();

    canvas.translate(viewport.center.x, viewport.center.y);
    canvas.scale(1 / viewport.zoom, 1 / viewport.zoom);
    Point offset = viewport.getOffset();
    canvas.translate(offset.x, offset.y);

    world.paint(canvas, size);
    world.graph.paint(canvas, size);

    intent?.paint(canvas, size);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant StopEditorPainter oldDelegate) => true;
}
