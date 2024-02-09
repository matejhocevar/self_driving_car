import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../common/components/toolbar.dart';
import '../common/primitives/point.dart';
import '../common/primitives/segment.dart';
import 'editors/graph_editor.dart';
import 'graph.dart';
import 'settings.dart';
import 'viewport.dart';
import 'virtual_world.dart';

class WorldHost extends StatefulWidget {
  const WorldHost({super.key});

  @override
  State<WorldHost> createState() => _WorldHostState();
}

class _WorldHostState extends State<WorldHost> {
  late Graph graph;
  late ViewPort viewport;

  bool isGraphEditorMode = false;

  @override
  void initState() {
    super.initState();

    Point p1 = Point(600, 240);
    Point p2 = Point(600, 460);

    Segment s1 = Segment(p1, p2);

    graph = Graph(
      points: [p1, p2],
      segments: [s1],
    );
    Size size =
        WidgetsBinding.instance.platformDispatcher.views.first.physicalSize;
    viewport = ViewPort(height: size.height, width: size.width);
  }

  void _toggleGraphEditor() {
    setState(() {
      isGraphEditorMode = !isGraphEditorMode;
    });
  }

  void _handleScroll(event) {
    if (event is PointerScrollEvent) {
      viewport.handleZoom(event.scrollDelta);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: MediaQuery.sizeOf(context).width,
          height: MediaQuery.sizeOf(context).height,
          child: Listener(
            onPointerSignal: _handleScroll,
            child: isGraphEditorMode
                ? GraphEditor(graph: graph, viewport: viewport)
                : VirtualWorld(graph: graph, viewport: viewport),
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
