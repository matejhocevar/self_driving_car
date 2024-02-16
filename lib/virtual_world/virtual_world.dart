import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/car.dart';
import '../common/components/progressbar.dart';
import '../common/components/toolbar.dart';
import '../common/components/visualizer.dart';
import '../common/constants/vehicles.dart';
import '../common/controls.dart';
import '../common/primitives/point.dart';
import '../common/sensor.dart';
import '../common/vehicle.dart';
import '../network/neural_network.dart';
import '../utils/math.dart';
import 'graph.dart';
import 'markings/start.dart';
import 'settings.dart';
import 'viewport.dart';
import 'world.dart';

class VirtualWorld extends StatefulWidget {
  const VirtualWorld({
    super.key,
    required this.world,
  });

  final World world;

  @override
  State<VirtualWorld> createState() => _VirtualWorldState();
}

class _VirtualWorldState extends State<VirtualWorld>
    with TickerProviderStateMixin {
  late final SharedPreferences prefs;
  AnimationController? _controller;

  late World world;
  late Graph graph;
  late ViewPort viewport;

  List<Car> cars = [];
  late Sensor sensor;
  List<Car> traffic = [];
  List<List<Offset>> roadBorders = [];

  Car? bestCar;
  double bestFitness = 0.01;

  bool virtualWorldLoaded = false;

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((p) {
      prefs = p;
      _generate();
    });

    world = widget.world;
    graph = widget.world.graph;
    viewport = widget.world.viewport;
  }

  Future<void> _generate() async {
    cars.addAll(await _generateCars(n: VirtualWorldSettings.trainingCarsN));
    traffic.addAll(_generateTraffic());

    roadBorders =
        world.roadBorders.map((s) => [s.p1.offset, s.p2.offset]).toList();

    RawKeyboard.instance.addListener(cars.first.controls.onKeyEvent);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_onUpdateListener);

    _controller!.repeat();

    setState(() {
      virtualWorldLoaded = true;
    });
  }

  Future<List<Car>> _generateCars({required int n}) async {
    List<Car> cars = [];
    Start? startMarking = world.markings.whereType<Start>().firstOrNull;
    Point startingPoint = startMarking?.center ?? Point(100, 100);
    Point direction = startMarking?.directionVector ?? Point(0, -1);

    for (int i = 0; i < n; i++) {
      Vehicle v = VirtualWorldSettings.trainingCarsModel;
      cars.add(
        Car(
          x: startingPoint.x,
          y: startingPoint.y,
          angle: -angle(direction) + math.pi / 2,
          width: v.size.width,
          height: v.size.height,
          brain: await _loadModel(),
          controlType: VirtualWorldSettings.controlType,
          vehicle: v,
          vehicleOpacity: VirtualWorldSettings.trainingCarsOpacity,
        ),
      );

      if (i != 0) {
        NeuralNetwork.mutate(
          cars[i].brain!,
          amount: VirtualWorldSettings.neuralNetworkMutation,
        );
      }
    }

    bestCar = cars.first;
    bestCar!.showSensor = VirtualWorldSettings.sensorShowRays;

    return cars;
  }

  List<Car> _generateTraffic() {
    List<Car> traffic = [];
    for (var l in VirtualWorldSettings.trafficLocations) {
      Vehicle v = vehicles
          .where((v) => v != VirtualWorldSettings.trainingCarsModel)
          .toList()[math.Random().nextInt(vehicles.length - 1)];
      traffic.add(
        Car(
          x: l.location.x,
          y: l.location.y,
          width: v.size.width,
          height: v.size.height,
          maxSpeed: 2,
          controlType: ControlType.dummy,
          vehicle: v,
        ),
      );
    }

    return traffic;
  }

  void _selectTheBestCar() {
    bestCar!.showSensor = false;
    bestCar!.vehicleOpacity = VirtualWorldSettings.trainingCarsOpacity;
    double maxFitness = cars.map((Car car) => car.fitness).reduce(math.max);
    bestCar = cars.firstWhere((Car c) => c.fitness == maxFitness);
    bestCar!.showSensor = true;
    bestCar!.vehicleOpacity = 1;
  }

  void _onUpdateListener() {
    setState(() {
      cars.forEach((Car c) {
        c.update(roadBorders, traffic);
      });
      _selectTheBestCar();
      traffic.forEach((Car c) => c.update(roadBorders, []));

      viewport.offset.x = -bestCar!.x;
      viewport.offset.y = -bestCar!.y;

      world.cars = cars;
      world.traffic = traffic;
      world.bestCar = bestCar;
    });
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

  Future<void> _handleSaveModel() async {
    await prefs.setString('bestBrain', bestCar!.brain.toString());
    await prefs.setDouble('bestFitness', bestCar!.y);
    print('Models successfully saved!');
  }

  Future<NeuralNetwork?> _loadModel() async {
    String? brain = prefs.getString('bestBrain');
    bestFitness = prefs.getDouble('bestFitness') ?? bestFitness;

    if (brain != null) {
      return NeuralNetwork.fromString(brain);
    }

    return null;
  }

  Future<void> _handleDiscardModel() async {
    await prefs.remove('bestBrain');
    await prefs.remove('bestFitness');
    print('Models disposed!');
  }

  void _handleReset() async {
    setState(() {
      RawKeyboard.instance.removeListener(cars.first.controls.onKeyEvent);
      _controller!.removeListener(_onUpdateListener);
      _controller!.dispose();
      _controller = null;

      virtualWorldLoaded = false;
      cars = [];
      traffic = [];
    });

    _generate();
  }

  @override
  Widget build(BuildContext context) {
    if (!virtualWorldLoaded) {
      return const Center(
        child: CircularProgressIndicator(
          color: VirtualWorldSettings.visualisationBackgroundColor,
        ),
      );
    }

    final int drivingCars = cars.where((Car c) => !c.damaged).length;
    final double simulationProgress =
        clampDouble(bestCar!.fitness / bestFitness, 0, 1);

    return GestureDetector(
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: Stack(children: [
        CustomPaint(
          painter: VirtualWorldPainter(
            world: widget.world,
          ),
        ),
        Positioned(
          top: VirtualWorldSettings.visualisationMargin,
          right: VirtualWorldSettings.visualisationMargin,
          child: CustomPaint(
            size: VirtualWorldSettings.visualisationNetworkGraphSize,
            painter: VisualiserPainter(network: bestCar!.brain!),
          ),
        ),
        Positioned(
          top: VirtualWorldSettings.visualisationMargin +
              VirtualWorldSettings.visualisationNetworkGraphSize.height +
              8,
          right: VirtualWorldSettings.visualisationMargin,
          child: Toolbar(
            size: VirtualWorldSettings.visualisationToolbarSize,
            backgroundColor: VirtualWorldSettings.visualisationBackgroundColor,
            borderRadius: VirtualWorldSettings.visualisationRadius,
            children: [
              const Text(
                'Cars: ',
                style: TextStyle(color: Colors.white),
              ),
              Container(
                width: 70,
                alignment: Alignment.centerRight,
                child: Text(
                  '$drivingCars / ${cars.length}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                iconSize: 20,
                tooltip: 'Reset',
                color: Colors.white,
                onPressed: _handleReset,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.save_alt),
                iconSize: 20,
                tooltip: 'Save model',
                color: Colors.white,
                onPressed: _handleSaveModel,
              ),
              IconButton(
                icon: const Icon(Icons.delete_forever),
                iconSize: 20,
                tooltip: 'Discard model',
                color: Colors.white,
                onPressed: _handleDiscardModel,
              ),
            ],
          ),
        ),
        Positioned(
          top: VirtualWorldSettings.visualisationMargin +
              VirtualWorldSettings.visualisationNetworkGraphSize.height +
              8 +
              (VirtualWorldSettings.visualisationToolbarSize.height -
                  VirtualWorldSettings.visualisationProgressBarSize.height),
          right: VirtualWorldSettings.visualisationMargin,
          child: ProgressBar(progress: simulationProgress),
        ),
      ]),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    RawKeyboard.instance.removeListener(cars.first.controls.onKeyEvent);
    super.dispose();
  }
}

class VirtualWorldPainter extends CustomPainter {
  const VirtualWorldPainter({
    required this.world,
  });

  final World world;

  @override
  void paint(Canvas canvas, Size size) {
    ViewPort viewport = world.viewport;

    canvas.drawPaint(Paint()..color = Colors.grey);

    canvas.save();

    canvas.translate(viewport.center.x, viewport.center.y);
    canvas.scale(1 / viewport.zoom, 1 / viewport.zoom);
    Point offset = viewport.getOffset();
    canvas.translate(offset.x, offset.y);
    world.paint(canvas, size, showStartMarkings: false);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant VirtualWorldPainter oldDelegate) => true;
}
