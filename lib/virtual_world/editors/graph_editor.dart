import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../common/canvas/blueprint.dart';
import '../../common/primitives/point.dart';
import '../../common/primitives/segment.dart';
import '../../shortest_path/dijkstra_algorithm.dart';
import '../../utils/math.dart';
import '../graph.dart';
import '../markings/start.dart';
import '../markings/target.dart';
import '../settings.dart';
import '../viewport.dart';
import '../world.dart';

class GraphEditor extends StatefulWidget {
  const GraphEditor({
    super.key,
    required this.world,
  });

  final World world;

  @override
  State<GraphEditor> createState() => _GraphEditorState();
}

class _GraphEditorState extends State<GraphEditor> {
  late Graph graph;
  late ViewPort viewport;

  Point? selected;
  Point? hovered;
  Point? mouse;

  bool isDragging = false;

  @override
  void initState() {
    super.initState();

    graph = widget.world.graph;
    viewport = widget.world.viewport;
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

  void _handleHover(event) {
    mouse = viewport.getMouse(Point.fromOffset(event.localPosition));
    hovered = getNearestPoint(
      mouse!,
      graph.points,
      threshold: VirtualWorldSettings.editorSelectedThreshold * viewport.zoom,
    );
    setState(() {});
  }

  void _handleTapDown(TapDownDetails tap) {
    Point p = viewport.getMouse(Point.fromOffset(tap.localPosition));
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
    isDragging = true;
    if (selected != hovered) {
      selected = hovered;
    }

    viewport.handlePanStart(Point.fromOffset(drag.localPosition));
    setState(() {});
  }

  void _handleDragUpdate(drag) {
    if (isDragging && selected != null) {
      Point p = viewport.getMouse(
        Point.fromOffset(drag.localPosition),
        subtractDragOffset: true,
      );
      selected!.x = p.x;
      selected!.y = p.y;
    } else {
      viewport.handlePanUpdate(Point.fromOffset(drag.localPosition));
    }

    setState(() {});
  }

  void _handleDragEnd(_) {
    isDragging = false;
    if (selected != null) {
      selected = null;
    }
    viewport.handlePanEnd();
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
      onHover: _handleHover,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onPanStart: _handleDragStart,
        onPanUpdate: _handleDragUpdate,
        onPanEnd: _handleDragEnd,
        onSecondaryTapDown: _handleSecondaryTapDown,
        child: CustomPaint(
          painter: GraphEditorPainter(
            world: widget.world,
            selected: selected,
            hovered: hovered,
            mouse: mouse,
          ),
        ),
      ),
    );
  }
}

class GraphEditorPainter extends CustomPainter {
  const GraphEditorPainter({
    required this.world,
    this.selected,
    this.hovered,
    this.mouse,
  });

  final World world;
  final Point? selected;
  final Point? hovered;
  final Point? mouse;

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

    if (selected != null) {
      Point intent = hovered != null ? hovered! : mouse!;
      Segment s = Segment(selected!, intent);
      s.paint(canvas, size, dash: [3, 3]);

      selected!.paint(canvas, size, outline: true);
    }

    hovered?.paint(canvas, size, fill: true);

    Point? startPoint =
        world.markings.whereType<Start>().firstOrNull?.polygon.points.first;
    Point? endPoint =
        world.markings.whereType<Target>().firstOrNull?.polygon.points.first;

    if (startPoint == null && endPoint == null) {
      List<Point> path = world.graph.findShortestPath(
        DijkstraAlgorithm(),
        startPoint!,
        endPoint!,
      );

      for (Point point in path) {
        point.paint(
          canvas,
          size,
          color: Colors.orange,
          radius: 24,
        );
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant GraphEditorPainter oldDelegate) => true;
}
