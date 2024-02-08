import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'components/progressbar.dart';
import 'components/toolbar.dart';
import 'components/visualizer.dart';
import 'constants/vehicles.dart';
import 'constants/world_settings.dart';
import 'models/car.dart';
import 'models/controls.dart';
import 'models/road.dart';
import 'models/sensor.dart';
import 'models/vehicle.dart';
import 'network/network.dart';

class World extends StatefulWidget {
  const World({super.key});

  @override
  State<World> createState() => _WorldState();
}

class _WorldState extends State<World> with SingleTickerProviderStateMixin {
  late final SharedPreferences prefs;
  late AnimationController _controller;

  bool worldLoaded = false;

  List<Car> cars = [];
  Car? bestCar;
  late Road road;
  final Size roadSize = WorldSettings.roadSize;
  late Sensor sensor;
  List<Car> traffic = [];

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((p) {
      prefs = p;
      _generateWorld();
    });
  }

  Future<void> _generateWorld() async {
    await loadAssets();

    road = Road(
      x: roadSize.width / 2,
      width: roadSize.width * 0.9,
      laneCount: WorldSettings.roadLaneCount,
    );
    cars.addAll(await _generateCars(n: WorldSettings.trainingCarsN));
    traffic.addAll(_generateTraffic());

    RawKeyboard.instance.addListener(cars.first.controls.onKeyEvent);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(() {
        setState(() {
          cars.forEach((Car c) => c.update(road.borders, traffic));
          _selectTheBestCar();

          traffic.forEach((Car c) => c.update(road.borders, []));
        });
      });

    _controller.repeat();

    setState(() {
      worldLoaded = true;
    });
  }

  Future<List<Car>> _generateCars({required int n}) async {
    List<Car> cars = [];
    for (int i = 0; i < n; i++) {
      Vehicle v = WorldSettings.trainingCarsModel;
      cars.add(
        Car(
          x: road.getLaneCenter(1),
          y: WorldSettings.trainingCarsStartingY,
          width: v.size.width,
          height: v.size.height,
          brain: await _loadModel(),
          controlType: WorldSettings.controlType,
          vehicle: v,
          vehicleOpacity: WorldSettings.trainingCarsOpacity,
        ),
      );

      if (i != 0) {
        NeuralNetwork.mutate(
          cars[i].brain!,
          amount: WorldSettings.neuralNetworkMutation,
        );
      }
    }

    bestCar = cars.first;
    bestCar!.showSensor = WorldSettings.sensorShowRays;

    return cars;
  }

  List<Car> _generateTraffic() {
    List<Car> traffic = [];
    for (var l in WorldSettings.trafficLocations) {
      Vehicle v = vehicles
          .where((v) => v != WorldSettings.trainingCarsModel)
          .toList()[math.Random().nextInt(vehicles.length - 1)];
      traffic.add(
        Car(
          x: road.getLaneCenter(l.lane),
          y: l.y,
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
    bestCar!.vehicleOpacity = WorldSettings.trainingCarsOpacity;
    double minY = cars.map((Car car) => car.y).reduce(math.min);
    bestCar = cars.firstWhere((Car c) => c.y == minY);
    bestCar!.showSensor = true;
    bestCar!.vehicleOpacity = 1;
  }

  _saveModel() async {
    await prefs.setString('bestBrain', bestCar!.brain.toString());
    print('Models successfully saved!');
  }

  Future<NeuralNetwork?> _loadModel() async {
    String? brain = prefs.getString('bestBrain');

    if (brain != null) {
      return NeuralNetwork.fromString(brain);
    }

    return null;
  }

  _discardModel() async {
    await prefs.remove('bestBrain');
    print('Models disposed!');
  }

  @override
  Widget build(BuildContext context) {
    if (!worldLoaded) {
      return const Center(
        child: CircularProgressIndicator(
          color: WorldSettings.visualisationBackgroundColor,
        ),
      );
    }

    final int drivingCars = cars.where((Car c) => !c.damaged).length;
    final double simulationProgress =
        clampDouble(bestCar!.y / traffic.last.y, 0, 1);

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(width: roadSize.width, color: const Color(0xFFDCDCDC)),
        CustomPaint(
          size: roadSize,
          painter: WorldPainter(
            road: road,
            cars: cars,
            bestCar: bestCar!,
            traffic: traffic,
          ),
        ),
        Positioned(
          top: WorldSettings.visualisationMargin,
          right: WorldSettings.visualisationMargin,
          child: CustomPaint(
            size: WorldSettings.visualisationNetworkGraphSize,
            painter: VisualiserPainter(network: bestCar!.brain!),
          ),
        ),
        Positioned(
          top: WorldSettings.visualisationMargin +
              WorldSettings.visualisationNetworkGraphSize.height +
              8,
          right: WorldSettings.visualisationMargin,
          child: Toolbar(
            size: WorldSettings.visualisationToolbarSize,
            children: [
              const Text(
                'Cars: ',
                style: TextStyle(color: Colors.white),
              ),
              Text(
                '$drivingCars / ${cars.length}',
                style: const TextStyle(color: Colors.white),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.save_alt),
                iconSize: 20,
                tooltip: 'Save model',
                color: Colors.white,
                onPressed: _saveModel,
              ),
              IconButton(
                icon: const Icon(Icons.delete_forever),
                iconSize: 20,
                tooltip: 'Discard model',
                color: Colors.white,
                onPressed: _discardModel,
              ),
            ],
          ),
        ),
        Positioned(
          top: WorldSettings.visualisationMargin +
              WorldSettings.visualisationNetworkGraphSize.height +
              8 +
              (WorldSettings.visualisationToolbarSize.height -
                  WorldSettings.visualisationProgressBarSize.height),
          right: WorldSettings.visualisationMargin,
          child: ProgressBar(progress: simulationProgress),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    RawKeyboard.instance.removeListener(cars.first.controls.onKeyEvent);
    super.dispose();
  }
}

class WorldPainter extends CustomPainter {
  const WorldPainter({
    required this.road,
    required this.cars,
    required this.bestCar,
    required this.traffic,
  });

  final Road road;
  final List<Car> cars;
  final Car bestCar;
  final List<Car> traffic;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    canvas.translate(0, -bestCar.y + size.height * 0.7);
    road.paint(canvas, size);

    for (int i = 0; i < traffic.length; i++) {
      traffic[i].paint(canvas, size);
    }

    cars.forEach((Car c) => c.paint(canvas, size));
    bestCar.paint(canvas, size);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
