import 'package:flutter/material.dart';
import 'package:self_driving_car/virtual_world/editors/graph_editor.dart';

import '../common/components/toolbar.dart';
import '../common/primitives/point.dart';
import '../common/primitives/segment.dart';
import 'graph.dart';
import 'settings.dart';

class VirtualWorld extends StatefulWidget {
  const VirtualWorld({super.key});

  @override
  State<VirtualWorld> createState() => _VirtualWorldState();
}

class _VirtualWorldState extends State<VirtualWorld> {
  late Graph graph;
  late GraphEditorCustomPainter graphEditor;
  bool isGraphEditorMode = false;

  @override
  void initState() {
    super.initState();

    Point p1 = Point(200, 200);
    Point p2 = Point(500, 200);
    Point p3 = Point(400, 400);
    Point p4 = Point(100, 300);

    Segment s1 = Segment(p1, p2);
    Segment s2 = Segment(p1, p3);
    Segment s3 = Segment(p1, p4);
    Segment s4 = Segment(p2, p3);

    graph = Graph(
      points: [p1, p2, p3, p4],
      segments: [s1, s2, s3, s4],
    );
    graphEditor = GraphEditorCustomPainter(graph: graph);
  }

  void _toggleGraphEditor() {
    setState(() {
      isGraphEditorMode = !isGraphEditorMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: MediaQuery.sizeOf(context).width,
          height: MediaQuery.sizeOf(context).height,
          child: isGraphEditorMode
              ? GraphEditor(graph: graph)
              : CustomPaint(
                  painter: VirtualWorldPainter(graph: graph),
                ),
        ),
        Positioned(
          bottom: VirtualWorldSettings.controlsMargin,
          child: Center(
            child: Toolbar(
              size: VirtualWorldSettings.controlsSize,
              backgroundColor: VirtualWorldSettings.controlsBackgroundColor,
              borderRadius: VirtualWorldSettings.controlsRadius,
              children: [
                const Spacer(),
                IconButton(
                  icon: Icon(
                    isGraphEditorMode ? Icons.remove_road : Icons.edit_road,
                  ),
                  iconSize: 20,
                  tooltip: 'Toggle Graph Editor',
                  color: Colors.white,
                  onPressed: _toggleGraphEditor,
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class VirtualWorldPainter extends CustomPainter {
  const VirtualWorldPainter({required this.graph});

  final Graph graph;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPaint(Paint()..color = Colors.grey);

    graph.paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant VirtualWorldPainter oldDelegate) =>
      oldDelegate.graph != graph;
}
