import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:self_driving_car/virtual_world/virtual_world.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/components/osm_dialog.dart';
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
import 'osm.dart';
import 'settings.dart';
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

enum WorldLoadingStatus {
  loaded,
  loading,
  saving,
  disposing,
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
  late Size size;

  WorldLoadingStatus loadingStatus = WorldLoadingStatus.loading;
  WorldMode _worldMode = WorldMode.preview;

  Timer? timer;

  bool showOSMDialog = false;

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

    size = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize;
    world = await _loadWorld(size: size);

    setState(() {
      loadingStatus = WorldLoadingStatus.loaded;
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
    if (event is ScaleUpdateDetails) {
      world.viewport.handleZoom(Offset(
        event.horizontalScale,
        event.verticalScale,
      ));
    }
    if (event is PointerScrollEvent) {
      world.viewport.handleZoom(event.scrollDelta);
      setState(() {});
    }
  }

  Future<World> _loadWorld({String? content, required Size size}) async {
    String? world = prefs.getString('world');
    return World.fromString(content ?? world, size: size);
  }

  Future<void> _handleSaveWorld() async {
    if (loadingStatus == WorldLoadingStatus.saving) {
      return;
    }

    setState(() {
      loadingStatus = WorldLoadingStatus.saving;
    });

    String? filePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Please select an output file:',
      fileName: 'world.world',
      lockParentWindow: true,
    );

    String worldStr = world.toString();

    // Save to cache
    prefs.setString('world', worldStr);

    if (filePath != null) {
      // Save to file
      List<int> list = utf8.encode(worldStr);
      Uint8List bytes = Uint8List.fromList(list);
      File file = File(filePath);
      await file.writeAsBytes(bytes);

      print('Successfully saved world model to $filePath');
    }

    setState(() {
      loadingStatus = WorldLoadingStatus.loaded;
    });
  }

  Future<void> _handleLoadWorld() async {
    if (loadingStatus == WorldLoadingStatus.loading) {
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowedExtensions: ['.world'],
      lockParentWindow: true,
    );

    setState(() {
      loadingStatus = WorldLoadingStatus.loading;
    });

    if (result != null) {
      File file = File(result.files.single.path!);
      String content = await file.readAsString();
      World newWorld = await _loadWorld(content: content, size: size);
      world.dispose();
      world = newWorld;
    }

    setState(() {
      loadingStatus = WorldLoadingStatus.loaded;
    });
  }

  void _handleOpenOSMDialog() {
    setState(() {
      showOSMDialog = true;
    });
  }

  Future<void> _handleOSMPaste(String str) async {
    // Load new model
    world.dispose();

    Graph graph = await OSM.parse(str, size: size);
    world = World(graph: graph, viewport: world.viewport);

    print('Successfully loaded world model from OSM data');

    setState(() {
      loadingStatus = WorldLoadingStatus.loaded;
    });
  }

  void _handleDisposeWorld() {
    if (loadingStatus == WorldLoadingStatus.disposing) {
      return;
    }

    setState(() {
      loadingStatus = WorldLoadingStatus.disposing;
    });

    world.dispose();
    prefs.remove('world');

    setState(() {
      loadingStatus = WorldLoadingStatus.loaded;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loadingStatus == WorldLoadingStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: VirtualWorldSettings.controlsBackgroundColor,
        ),
      );
    }

    Widget worldModeWidget = switch (_worldMode) {
      WorldMode.roadEditor => GraphEditor(world: world),
      WorldMode.stopEditor => StopEditor(
          world: world,
          targetSegments: world.laneGuides,
        ),
      WorldMode.startEditor => StartEditor(
          world: world,
          vehicle: vehicles.firstWhere((v) => v.name == 'car_sport_red'),
          targetSegments: world.laneGuides,
        ),
      WorldMode.targetEditor => TargetEditor(
          world: world,
          targetSegments: world.laneGuides,
        ),
      WorldMode.yieldEditor => YieldEditor(
          world: world,
          targetSegments: world.laneGuides,
        ),
      WorldMode.crossingEditor => CrossingEditor(
          world: world,
          targetSegments: world.graph.segments,
        ),
      WorldMode.trafficLightEditor => TrafficLightEditor(
          world: world,
          targetSegments: world.laneGuides,
        ),
      WorldMode.parkingEditor => ParkingEditor(
          world: world,
          targetSegments: world.laneGuides,
        ),
      WorldMode.preview || WorldMode.unknown => VirtualWorld(world: world),
    };

    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (SizeChangedLayoutNotification notification) {
        size =
            WidgetsBinding.instance.platformDispatcher.views.first.physicalSize;
        return true;
      },
      child: SizeChangedLayoutNotifier(
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onScaleUpdate: _handleScroll,
              child: Listener(
                onPointerSignal: _handleScroll,
                child: Container(
                  color: Colors.transparent,
                  width: MediaQuery.sizeOf(context).width,
                  height: MediaQuery.sizeOf(context).height,
                  child: worldModeWidget,
                ),
              ),
            ),
            if (showOSMDialog)
              Positioned(
                top: 0,
                left: 0,
                child: OSMDialog(
                  onDismiss: () => setState(() {
                    showOSMDialog = false;
                  }),
                  onSubmit: (String str) async {
                    setState(() {
                      showOSMDialog = false;
                      loadingStatus = WorldLoadingStatus.loading;
                    });
                    await _handleOSMPaste(str);
                  },
                ),
              ),
            Positioned(
              left: VirtualWorldSettings.controlsMargin,
              child: Center(
                child: Toolbar(
                  direction: Axis.vertical,
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
                      tooltip: 'Save world',
                      isActive: loadingStatus == WorldLoadingStatus.saving,
                      onTap: _handleSaveWorld,
                    ),
                    ToolbarIcon(
                      icon: Icons.folder_open,
                      tooltip: 'Load world',
                      isActive: loadingStatus == WorldLoadingStatus.loading,
                      onTap: _handleLoadWorld,
                    ),
                    ToolbarIcon(
                      icon: Icons.code_outlined,
                      tooltip: 'Paste OSM data',
                      isActive: loadingStatus == WorldLoadingStatus.loading,
                      onTap: _handleOpenOSMDialog,
                    ),
                    ToolbarIcon(
                      icon: Icons.delete_forever,
                      tooltip: 'Dispose world',
                      isActive: loadingStatus == WorldLoadingStatus.disposing,
                      onTap: _handleDisposeWorld,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}
