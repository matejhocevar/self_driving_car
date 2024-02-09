import 'package:flutter/material.dart';

import '../common/primitives/point.dart';
import 'graph.dart';
import 'viewport.dart';

class VirtualWorld extends StatefulWidget {
  const VirtualWorld({
    super.key,
    required this.graph,
    required this.viewport,
  });

  final Graph graph;
  final ViewPort viewport;

  @override
  State<VirtualWorld> createState() => _VirtualWorldState();
}

class _VirtualWorldState extends State<VirtualWorld> {
  late Graph graph;
  late ViewPort viewport;

  @override
  void initState() {
    super.initState();

    graph = widget.graph;
    viewport = widget.viewport;
  }

  void _handlePanStart(DragStartDetails e) {
    viewport.handlePanStart(Point.fromOffset(e.localPosition));

    setState(() {});
  }

  void _handlePanUpdate(DragUpdateDetails e) {
    viewport.handlePanUpdate(Point.fromOffset(e.localPosition));
    setState(() {});
  }

  void _handlePanEnd(event) {
    viewport.handlePanEnd();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: CustomPaint(
        painter: VirtualWorldPainter(
          graph: graph,
          viewport: viewport,
        ),
      ),
    );
  }
}

class VirtualWorldPainter extends CustomPainter {
  const VirtualWorldPainter({
    required this.graph,
    required this.viewport,
  });

  final Graph graph;
  final ViewPort viewport;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPaint(Paint()..color = Colors.grey);

    canvas.save();

    canvas.translate(viewport.center.x, viewport.center.y);
    canvas.scale(1 / viewport.zoom, 1 / viewport.zoom);
    Point offset = viewport.getOffset();
    canvas.translate(offset.x, offset.y);
    graph.paint(canvas, size);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant VirtualWorldPainter oldDelegate) => true;
}
