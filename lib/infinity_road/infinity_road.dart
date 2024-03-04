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
import '../common/sensor.dart';
import '../common/vehicle.dart';
import '../neural_network/neural_network.dart';
import 'road.dart';
import 'settings.dart';

class InfinityRoad extends StatefulWidget {
  const InfinityRoad({super.key});

  @override
  State<InfinityRoad> createState() => _InfinityRoadState();
}

class _InfinityRoadState extends State<InfinityRoad>
    with TickerProviderStateMixin {
  late final SharedPreferences prefs;
  AnimationController? _controller;

  bool infinityRoadLoaded = false;

  List<Car> cars = [];
  late Road road;
  final Size roadSize = InfinityRoadSettings.roadSize;
  late Sensor sensor;
  List<Car> traffic = [];

  Car? bestCar;
  double bestFitness = 0.01;

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((p) {
      prefs = p;
      _generateInfinityRoad();
    });
  }

  Future<void> _generateInfinityRoad() async {
    await loadAssets();

    road = Road(
      x: roadSize.width / 2,
      width: roadSize.width * 0.9,
      laneCount: InfinityRoadSettings.roadLaneCount,
    );
    cars.addAll(await _generateCars(n: InfinityRoadSettings.trainingCarsN));
    traffic.addAll(_generateTraffic());
    RawKeyboard.instance.addListener(cars.first.controls.onKeyEvent);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_onUpdateListener);

    _controller!.repeat();

    setState(() {
      infinityRoadLoaded = true;
    });
  }

  void _onUpdateListener() {
    setState(() {
      road.update(bestCar!.y);

      cars.forEach((Car c) {
        c.update(road.borders, traffic);

        // Damage car if it lags behind
        if (c.y - bestCar!.y > 500) {
          c.damaged = true;
        }
      });
      _selectTheBestCar();

      traffic.forEach((Car c) => c.update(road.borders, []));
    });
  }

  Future<List<Car>> _generateCars({required int n}) async {
    List<Car> cars = [];
    for (int i = 0; i < n; i++) {
      Vehicle v = InfinityRoadSettings.trainingCarsModel;
      cars.add(
        Car(
          x: road.getLaneCenter(1),
          y: InfinityRoadSettings.trainingCarsStartingY,
          width: v.size.width,
          height: v.size.height,
          brain: await _loadModel(),
          controlType: InfinityRoadSettings.controlType,
          vehicle: v,
          vehicleOpacity: InfinityRoadSettings.trainingCarsOpacity,
        ),
      );

      if (i != 0) {
        NeuralNetwork.mutate(
          cars[i].brain!,
          amount: InfinityRoadSettings.neuralNetworkMutation,
        );
      }
    }

    bestCar = cars.first;
    bestCar!.showSensor = InfinityRoadSettings.sensorShowRays;

    return cars;
  }

  List<Car> _generateTraffic() {
    List<Car> traffic = [];
    for (var l in InfinityRoadSettings.trafficLocations) {
      Vehicle v = vehicles
          .where((v) => v != InfinityRoadSettings.trainingCarsModel)
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
    bestCar!.vehicleOpacity = InfinityRoadSettings.trainingCarsOpacity;
    double maxFitness = cars.map((Car car) => car.fitness).reduce(math.max);
    bestCar = cars.firstWhere((Car c) => c.fitness == maxFitness);
    bestCar!.showSensor = true;
    bestCar!.vehicleOpacity = 1;
  }

  _saveModel() async {
    await prefs.setString('bestBrain', bestCar!.brain.toString());
    await prefs.setDouble('bestFitness', bestCar!.fitness);
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

  _discardModel() async {
    await prefs.remove('bestBrain');
    await prefs.remove('bestFitness');
    print('Models disposed!');
  }

  void _reset() async {
    setState(() {
      RawKeyboard.instance.removeListener(cars.first.controls.onKeyEvent);
      _controller!.removeListener(_onUpdateListener);
      _controller!.dispose();
      _controller = null;

      infinityRoadLoaded = false;
      cars = [];
      traffic = [];
    });

    _generateInfinityRoad();
  }

  @override
  Widget build(BuildContext context) {
    if (!infinityRoadLoaded) {
      return const Center(
        child: CircularProgressIndicator(
          color: InfinityRoadSettings.visualisationBackgroundColor,
        ),
      );
    }

    final int drivingCars = cars.where((Car c) => !c.damaged).length;
    final double simulationProgress =
        clampDouble(bestCar!.y / bestFitness, 0, 1);

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(width: roadSize.width, color: const Color(0xFFDCDCDC)),
        CustomPaint(
          size: roadSize,
          painter: InfinityRoadPainter(
            road: road,
            cars: cars,
            bestCar: bestCar!,
            traffic: traffic,
          ),
        ),
        Positioned(
          top: InfinityRoadSettings.visualisationMargin,
          right: InfinityRoadSettings.visualisationMargin,
          child: CustomPaint(
            size: InfinityRoadSettings.visualisationNetworkGraphSize,
            painter: VisualiserPainter(network: bestCar!.brain!),
          ),
        ),
        Positioned(
          top: InfinityRoadSettings.visualisationMargin +
              InfinityRoadSettings.visualisationNetworkGraphSize.height +
              8,
          right: InfinityRoadSettings.visualisationMargin,
          child: Toolbar(
            size: InfinityRoadSettings.visualisationToolbarSize,
            backgroundColor: InfinityRoadSettings.visualisationBackgroundColor,
            borderRadius: InfinityRoadSettings.visualisationRadius,
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
                onPressed: _reset,
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
          top: InfinityRoadSettings.visualisationMargin +
              InfinityRoadSettings.visualisationNetworkGraphSize.height +
              8 +
              (InfinityRoadSettings.visualisationToolbarSize.height -
                  InfinityRoadSettings.visualisationProgressBarSize.height),
          right: InfinityRoadSettings.visualisationMargin,
          child: ProgressBar(progress: simulationProgress),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    RawKeyboard.instance.removeListener(cars.first.controls.onKeyEvent);
    super.dispose();
  }
}

class InfinityRoadPainter extends CustomPainter {
  const InfinityRoadPainter({
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
