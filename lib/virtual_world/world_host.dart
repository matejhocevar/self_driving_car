import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/components/toolbar.dart';
import '../common/components/toolbar_icon.dart';
import '../common/constants/vehicles.dart';
import 'editors/crossing_editor.dart';
import 'editors/graph_editor.dart';
import 'editors/parking_editor.dart';
import 'editors/start_editor.dart';
import 'editors/stop_editor.dart';
import 'editors/target_editor.dart';
import 'editors/traffic_light_editor.dart';
import 'editors/yield_editor.dart';
import 'graph.dart';
import 'settings.dart';
import 'viewport.dart';
import 'virtual_world.dart';
import 'world.dart';

enum WorldMode {
  unknown,
  preview,
  roadEditor,
  crossingEditor,
  trafficLightEditor,
  parkingEditor,
  stopEditor,
  yieldEditor,
  startEditor,
  targetEditor,
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

  Timer? timer;

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((p) async {
      prefs = p;

      await _generateVirtualWorld();

      timer?.cancel();
      timer = Timer.periodic(const Duration(seconds: 1),
          (Timer timer) => _onUpdateListener(timer.tick));
    });
  }

  Future<void> _generateVirtualWorld() async {
    await loadAssets();

    Size size =
        WidgetsBinding.instance.platformDispatcher.views.first.physicalSize;
    viewport = ViewPort(height: size.height, width: size.width);
    world = await _loadWorld(viewport);

    setState(() {
      virtualWorldLoaded = true;
    });
  }

  void _setWorldMode(WorldMode mode) {
    setState(() {
      _worldMode = mode;
    });
  }

  void _onUpdateListener(int tick) {
    world.updateLights(tick);
    setState(() {});
  }

  void _handleScroll(event) {
    if (event is PointerScrollEvent) {
      viewport.handleZoom(event.scrollDelta);
      setState(() {});
    }
  }

  Future<World> _loadWorld(ViewPort viewport) async {
    String? world = prefs.getString('world');
    return World.fromString(world, viewport: viewport);
  }

  Future<void> _handleSaveWorld() async {
    prefs.setString('world', world.toString());
  }

  void _handleDisposeWorld() {
    world.dispose();
    prefs.remove('world');
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
      WorldMode.startEditor => StartEditor(
          world: world,
          viewport: viewport,
          vehicle: vehicles.firstWhere((v) => v.name == 'car_sport_red'),
          targetSegments: world.laneGuides,
        ),
      WorldMode.targetEditor => TargetEditor(
          world: world,
          viewport: viewport,
          targetSegments: world.laneGuides,
        ),
      WorldMode.yieldEditor => YieldEditor(
          world: world,
          viewport: viewport,
          targetSegments: world.laneGuides,
        ),
      WorldMode.crossingEditor => CrossingEditor(
          world: world,
          viewport: viewport,
          targetSegments: world.graph.segments,
        ),
      WorldMode.trafficLightEditor => TrafficLightEditor(
          world: world,
          viewport: viewport,
          targetSegments: world.laneGuides,
        ),
      WorldMode.parkingEditor => ParkingEditor(
          world: world,
          viewport: viewport,
          targetSegments: world.laneGuides,
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
                  icon: Icons.merge,
                  tooltip: 'Yield editor',
                  isActive: _worldMode == WorldMode.yieldEditor,
                  onTap: () => _setWorldMode(WorldMode.yieldEditor),
                ),
                ToolbarIcon(
                  icon: Icons.traffic,
                  tooltip: 'Traffic light editor',
                  isActive: _worldMode == WorldMode.trafficLightEditor,
                  onTap: () => _setWorldMode(WorldMode.trafficLightEditor),
                ),
                ToolbarIcon(
                  icon: Icons.directions_walk,
                  tooltip: 'Crossing editor',
                  isActive: _worldMode == WorldMode.crossingEditor,
                  onTap: () => _setWorldMode(WorldMode.crossingEditor),
                ),
                ToolbarIcon(
                  icon: Icons.local_parking,
                  tooltip: 'Parking editor',
                  isActive: _worldMode == WorldMode.parkingEditor,
                  onTap: () => _setWorldMode(WorldMode.parkingEditor),
                ),
                ToolbarIcon(
                  icon: Icons.directions_car,
                  tooltip: 'Start/Spawn editor',
                  isActive: _worldMode == WorldMode.startEditor,
                  onTap: () => _setWorldMode(WorldMode.startEditor),
                ),
                ToolbarIcon(
                  icon: Icons.adjust,
                  tooltip: 'Target editor',
                  isActive: _worldMode == WorldMode.targetEditor,
                  onTap: () => _setWorldMode(WorldMode.targetEditor),
                ),
                const Spacer(),
                ToolbarIcon(
                  icon: Icons.save,
                  tooltip: 'Save Graph',
                  onTap: _handleSaveWorld,
                ),
                ToolbarIcon(
                  icon: Icons.delete_forever,
                  tooltip: 'Dispose Graph',
                  onTap: _handleDisposeWorld,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}
