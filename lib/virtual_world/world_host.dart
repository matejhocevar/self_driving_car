import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/components/toolbar.dart';
import '../common/components/toolbar_icon.dart';
import 'editors/crossing_editor.dart';
import 'editors/graph_editor.dart';
import 'editors/stop_editor.dart';
import 'graph.dart';
import 'settings.dart';
import 'viewport.dart';
import 'virtual_world.dart';
import 'world.dart';

enum WorldMode {
  unknown,
  preview,
  roadEditor,
  stopEditor,
  crossingEditor,
}

class WorldHost extends StatefulWidget {
  const WorldHost({super.key});

  @override
  State<WorldHost> createState() => _WorldHostState();
}

class _WorldHostState extends State<WorldHost> {
  late final SharedPreferences prefs;

  late World world;
  late Graph graph;
  late ViewPort viewport;

  bool virtualWorldLoaded = false;
  WorldMode _worldMode = WorldMode.preview;

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
    world = World(
      graph: graph,
      viewport: viewport,
      roadWidth: VirtualWorldSettings.roadWidth,
      roadRoundness: VirtualWorldSettings.roadRoundness,
      buildingWidth: VirtualWorldSettings.buildingWidth,
      buildingMinLength: VirtualWorldSettings.buildingMinLength,
      spacing: VirtualWorldSettings.buildingSpacing,
      treeSize: VirtualWorldSettings.treeSize,
      treeTryCount: VirtualWorldSettings.treeTryCount,
    );

    setState(() {
      virtualWorldLoaded = true;
    });
  }

  void _setWorldMode(WorldMode mode) {
    setState(() {
      _worldMode = mode;
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
    world.dispose();
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

    Widget worldModeWidget = switch (_worldMode) {
      WorldMode.roadEditor => GraphEditor(world: world, viewport: viewport),
      WorldMode.stopEditor => StopEditor(
          world: world,
          viewport: viewport,
          targetSegments: world.laneGuides,
        ),
      WorldMode.crossingEditor => CrossingEditor(
          world: world,
          viewport: viewport,
          targetSegments: world.graph.segments,
        ),
      WorldMode.preview || WorldMode.unknown => VirtualWorld(
          world: world,
          viewport: viewport,
        ),
    };

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: MediaQuery.sizeOf(context).width,
          height: MediaQuery.sizeOf(context).height,
          child: Listener(
            onPointerSignal: _handleScroll,
            child: worldModeWidget,
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
                ToolbarIcon(
                  icon: Icons.public,
                  tooltip: 'World preview',
                  isActive: _worldMode == WorldMode.preview,
                  onTap: () => _setWorldMode(WorldMode.preview),
                ),
                ToolbarIcon(
                  icon: Icons.edit_road,
                  tooltip: 'Road editor',
                  isActive: _worldMode == WorldMode.roadEditor,
                  onTap: () => _setWorldMode(WorldMode.roadEditor),
                ),
                ToolbarIcon(
                  icon: Icons.dangerous,
                  tooltip: 'Stop editor',
                  isActive: _worldMode == WorldMode.stopEditor,
                  onTap: () => _setWorldMode(WorldMode.stopEditor),
                ),
                ToolbarIcon(
                  icon: Icons.directions_walk,
                  tooltip: 'Crossing editor',
                  isActive: _worldMode == WorldMode.crossingEditor,
                  onTap: () => _setWorldMode(WorldMode.crossingEditor),
                ),
                const Spacer(),
                ToolbarIcon(
                  icon: Icons.save,
                  tooltip: 'Save Graph',
                  onTap: _handleSaveGraph,
                ),
                ToolbarIcon(
                  icon: Icons.delete_forever,
                  tooltip: 'Dispose Graph',
                  onTap: _handleDisposeGraph,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
