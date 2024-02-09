import 'package:flutter/material.dart';

import '../../common/primitives/point.dart';
import '../../common/primitives/segment.dart';
import '../../utils/math.dart';
import '../graph.dart';
import '../settings.dart';

class GraphEditor extends StatefulWidget {
  const GraphEditor({super.key, required this.graph});

  final Graph graph;

  @override
  State<GraphEditor> createState() => _GraphEditorState();
}

class _GraphEditorState extends State<GraphEditor> {
  late Graph graph;

  Point? selected;
  Point? hovered;
  Point? mouse;

  bool isDragging = false;

  @override
  void initState() {
    super.initState();

    graph = widget.graph;
  }

  void _removePoint(Point? p) {
    if (p == null) {
      return;
    }

    graph.removePoint(p);
    hovered = null;

    if (selected == p) {
      selected = null;
    }
  }

  void _select(Point point) {
    if (selected != null) {
      graph.tryAddSegment(Segment(selected!, point));
    }

    selected = point;
  }

  void _handleTapDown(TapDownDetails tap) {
    Point p = Point.fromOffset(tap.localPosition);
    if (hovered != null) {
      _select(hovered!);

      setState(() {});
      return;
    }

    if (graph.tryAddPoint(p)) {
      _select(p);
      hovered = p;

      setState(() {});
    }
  }

  void _handleDragStart(drag) {
    setState(() {
      isDragging = true;
      if (selected != hovered) {
        selected = hovered;
      }
    });
  }

  void _handleDragUpdate(drag) {
    if (isDragging && selected != null) {
      selected!.x = drag.localPosition.dx;
      selected!.y = drag.localPosition.dy;
      setState(() {});
    }
  }

  void _handleDragEnd(_) {
    isDragging = false;
    if (selected != null) {
      selected = null;
    }
    setState(() {});
  }

  void _handleSecondaryTapDown(tap) {
    if (selected != null) {
      selected = null;
    } else if (hovered != null) {
      _removePoint(hovered);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) {
        mouse = Point.fromOffset(event.localPosition);
        hovered = getNearestPoint(
          mouse!,
          graph.points,
          threshold: VirtualWorldSettings.graphEditorSelectedThreshold,
        );
        setState(() {});
      },
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onPanStart: _handleDragStart,
        onPanUpdate: _handleDragUpdate,
        onPanEnd: _handleDragEnd,
        onSecondaryTapDown: _handleSecondaryTapDown,
        child: CustomPaint(
          painter: GraphEditorCustomPainter(
            graph: widget.graph,
            selected: selected,
            hovered: hovered,
            mouse: mouse,
          ),
        ),
      ),
    );
  }
}

class GraphEditorCustomPainter extends CustomPainter {
  const GraphEditorCustomPainter({
    required this.graph,
    this.selected,
    this.hovered,
    this.mouse,
  });

  final Graph graph;
  final Point? selected;
  final Point? hovered;
  final Point? mouse;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPaint(Paint()..color = Colors.green);

    graph.paint(canvas, size);

    if (selected != null) {
      Point intent = hovered != null ? hovered! : mouse!;
      Segment s = Segment(selected!, intent);
      s.paint(canvas, size, dash: [3, 3]);

      selected!.paint(canvas, size, outline: true);
    }

    if (hovered != null) {
      hovered!.paint(canvas, size, fill: true);
    }
  }

  @override
  bool shouldRepaint(covariant GraphEditorCustomPainter oldDelegate) =>
      oldDelegate.graph == graph;
}
