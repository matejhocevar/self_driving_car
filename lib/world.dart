import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:self_driving_car/car.dart';
import 'package:self_driving_car/painters/world_painter.dart';

import 'controls.dart';
import 'painters/car_painter.dart';
import 'painters/road_painter.dart';
import 'road.dart';

class World extends StatefulWidget {
  const World({super.key});

  @override
  State<World> createState() => _WorldState();
}

class _WorldState extends State<World> with SingleTickerProviderStateMixin {
  late Car car;
  late Road road;

  late AnimationController _controller;

  final Size size = const Size(200, double.infinity);

  @override
  void initState() {
    super.initState();

    road = Road(x: size.width / 2, width: size.width * 0.9, laneCount: 3);
    car = Car(
      x: road.getLaneCenter(1),
      y: 100,
      width: 30,
      height: 50,
      controls: Controls(),
    );

    RawKeyboard.instance.addListener(car.controls.onKeyEvent);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(() {
        setState(() {
          car.update();
        });
      });

    _controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(width: size.width, color: const Color(0xFFDCDCDC)),
        CustomPaint(
          size: size,
          painter: WorldPainter(
            roadPainter: RoadPainter(road: road),
            carPainter: CarPainter(car: car),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    RawKeyboard.instance.removeListener(car.controls.onKeyEvent);
    super.dispose();
  }
}
