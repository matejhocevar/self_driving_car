import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'components/progressbar.dart';
import 'components/toolbar.dart';
import 'components/visualizer.dart';
import 'models/car.dart';
import 'models/controls.dart';
import 'models/road.dart';
import 'models/sensor.dart';
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
  final Size roadSize = const Size(200, double.infinity);
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
    road = Road(
      x: roadSize.width / 2,
      width: roadSize.width * 0.9,
      laneCount: 3,
    );
    cars.addAll(await _generateCars(n: 100));
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
      cars.add(
        Car(
          x: road.getLaneCenter(1),
          y: 100,
          width: 30,
          height: 50,
          brain: await _loadModel(),
          controlType: ControlType.AI,
        ),
      );

      if (i != 0) {
        NeuralNetwork.mutate(cars[i].brain!, amount: 0.1);
      }
    }

    bestCar = cars.first;
    bestCar!.showSensor = true;

    return cars;
  }

  List<Car> _generateTraffic() {
    List<({int lane, double y})> locations = [
      (lane: 1, y: -100),
      (lane: 0, y: -300),
      (lane: 2, y: -300),
      (lane: 0, y: -500),
      (lane: 1, y: -500),
      (lane: 1, y: -700),
      (lane: 2, y: -700),
      (lane: 2, y: -800),
      (lane: 1, y: -900),
      (lane: 0, y: -1100),
      (lane: 0, y: -1300),
      (lane: 2, y: -1300),
      (lane: 1, y: -1450),
      (lane: 0, y: -1600),
      (lane: 2, y: -1600),
      (lane: 1, y: -1800),
    ];

    return locations
        .map(
          (l) => Car(
            x: road.getLaneCenter(l.lane),
            y: l.y,
            width: 30,
            height: 50,
            maxSpeed: 2,
            controlType: ControlType.dummy,
            color: Colors.purpleAccent,
          ),
        )
        .toList();
  }

  void _selectTheBestCar() {
    bestCar!.showSensor = false;
    bestCar!.color = null;
    double minY = cars.map((Car car) => car.y).reduce(math.min);
    bestCar = cars.firstWhere((Car c) => c.y == minY);
    bestCar!.showSensor = true;
    bestCar!.color = Colors.blue;
  }

  _saveModel() async {
    await prefs.setString('bestBrain', bestCar!.brain.toString());
    print('Models successfully saved!');
  }

  Future<NeuralNetwork?> _loadModel() async {
    String? brain = prefs.getString('bestBrain');

    if (brain != null) {
      print('Models successfully loaded!');
      return NeuralNetwork.fromString(brain);
    }

    print('No model found!');
  }

  _discardModel() async {
    await prefs.remove('bestBrain');
  }

  @override
  Widget build(BuildContext context) {
    if (!worldLoaded) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.black87),
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
          top: 16,
          right: 16,
          child: CustomPaint(
            size: const Size(250, 250),
            painter: VisualiserPainter(network: bestCar!.brain!),
          ),
        ),
        Positioned(
          top: 16 + 250 + 8,
          right: 16,
          child: Toolbar(
            size: const Size(250, 36),
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
          top: 16 + 250 + 8 + 32,
          right: 16,
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
