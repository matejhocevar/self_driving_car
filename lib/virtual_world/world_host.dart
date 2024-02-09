import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/components/toolbar.dart';
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
  late final SharedPreferences prefs;

  late Graph graph;
  late ViewPort viewport;

  bool virtualWorldLoaded = false;
  bool isGraphEditorMode = false;

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((p) async {
      prefs = p;

      _generateVirtualWorld();
    });
  }

  Future<void> _generateVirtualWorld() async {
    graph = await _loadGraph() ?? Graph();
    Size size =
        WidgetsBinding.instance.platformDispatcher.views.first.physicalSize;
    viewport = ViewPort(height: size.height, width: size.width);

    setState(() {
      virtualWorldLoaded = true;
    });
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

  Future<Graph?> _loadGraph() async {
    String? graph = prefs.getString('graph');
    if (graph != null) {
      return Graph.fromString(graph);
    }

    return null;
  }

  Future<void> _handleSaveGraph() async {
    prefs.setString('graph', graph.toString());
  }

  void _handleDisposeGraph() {
    graph.dispose();
    prefs.remove('graph');
  }

  @override
  Widget build(BuildContext context) {
    if (!virtualWorldLoaded) {
      return const Center(
        child: CircularProgressIndicator(
          color: VirtualWorldSettings.controlsBackgroundColor,
        ),
      );
    }

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
                IconButton(
                  icon: const Icon(Icons.save),
                  iconSize: 20,
                  tooltip: 'Save Graph',
                  color: Colors.white,
                  onPressed: _handleSaveGraph,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_forever),
                  iconSize: 20,
                  tooltip: 'Dispose Graph',
                  color: Colors.white,
                  onPressed: _handleDisposeGraph,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
