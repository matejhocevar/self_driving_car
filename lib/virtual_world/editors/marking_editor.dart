import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../common/canvas/blueprint.dart';
import '../../common/primitives/point.dart';
import '../../common/primitives/polygon.dart';
import '../../common/primitives/segment.dart';
import '../../utils/math.dart';
import '../graph.dart';
import '../markings/marking.dart';
import '../settings.dart';
import '../viewport.dart';
import '../world.dart';

abstract class MarkingEditor extends StatefulWidget {
  const MarkingEditor({
    Key? key,
    required this.world,
    required this.targetSegments,
  }) : super(key: key);

  final World world;
  final List<Segment> targetSegments;

  @override
  State<MarkingEditor> createState() => _MarkingEditorState();

  List<Marking> get markings => world.markings;

  void addMarking(Marking marking) {
    markings.add(marking);
  }

  void removeMarkingAt(int index) {
    markings.removeAt(index);
  }

  Marking createMarking(Point position, Segment segment);
}

class _MarkingEditorState extends State<MarkingEditor> {
  late Graph graph;
  late ViewPort viewport;

  Point? mouse;
  Marking? intent;

  @override
  void initState() {
    super.initState();
    graph = widget.world.graph;
    viewport = widget.world.viewport;
  }

  void _handleHover(PointerHoverEvent event) {
    mouse = viewport.getMouse(
      Point.fromOffset(event.localPosition),
      subtractDragOffset: true,
    );

    Segment? segment = getNearestSegment(
      mouse!,
      widget.targetSegments,
      threshold: VirtualWorldSettings.editorSelectedThreshold * viewport.zoom,
    );

    if (segment != null) {
      final (projPoint, offset) = segment.projectPoint(mouse!);
      if (offset >= 0 && offset <= 1) {
        intent = widget.createMarking(projPoint, segment);
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
      widget.addMarking(intent!);
      intent = null;
      setState(() {});
    }
  }

  void _handleSecondaryTapDown(_) {
    for (int i = 0; i < widget.markings.length; i++) {
      Polygon p = widget.markings[i].polygon;
      if (p.containsPoint(mouse!)) {
        widget.removeMarkingAt(i);
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
          painter: MarkingEditorPainter(
            world: widget.world,
            mouse: mouse,
            intent: intent,
          ),
        ),
      ),
    );
  }
}

class MarkingEditorPainter extends CustomPainter {
  const MarkingEditorPainter({
    required this.world,
    this.mouse,
    this.intent,
  });

  final World world;
  final Point? mouse;
  final Marking? intent;

  @override
  void paint(Canvas canvas, Size size) {
    ViewPort viewport = world.viewport;

    BlueprintPainter().paint(canvas, size, viewport: viewport);

    canvas.save();
    canvas.translate(viewport.center.x, viewport.center.y);
    canvas.scale(1 / viewport.zoom, 1 / viewport.zoom);
    Point offset = viewport.getOffset();
    canvas.translate(offset.x, offset.y);

    world.paint(canvas, size, renderRadius: double.infinity);
    world.graph.paint(canvas, size);

    intent?.paint(canvas, size);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant MarkingEditorPainter oldDelegate) => true;
}
