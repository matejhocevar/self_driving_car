import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'models/car.dart';
import 'models/controls.dart';
import 'models/road.dart';
import 'models/sensor.dart';

class World extends StatefulWidget {
  const World({super.key});

  @override
  State<World> createState() => _WorldState();
}

class _WorldState extends State<World> with SingleTickerProviderStateMixin {
  late Car car;
  late Road road;
  late Sensor sensor;

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
          car.update(road.borders);
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
            roadPainter: road,
            carPainter: car,
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

class WorldPainter extends CustomPainter {
  const WorldPainter({
    required this.roadPainter,
    required this.carPainter,
  });

  final Road roadPainter;
  final Car carPainter;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    canvas.translate(0, -carPainter.y + size.height * 0.7);

    roadPainter.paint(canvas, size);
    carPainter.paint(canvas, size);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
