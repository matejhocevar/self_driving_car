import 'package:flutter/material.dart';
import 'package:self_driving_car/car.dart';

import 'controls.dart';

class World extends StatefulWidget {
  const World({super.key});

  @override
  State<World> createState() => _WorldState();
}

class _WorldState extends State<World> with SingleTickerProviderStateMixin {
  late Car car;
  late Function(RawKeyEvent) onKeyEvent;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    car = Car(x: 100, y: 100, width: 30, height: 50, controls: Controls());

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
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (e) => car.controls.onKeyEvent(e),
      child: CustomPaint(
        size: const Size(200, double.infinity),
        painter: WorldPainter(car: car),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class WorldPainter extends CustomPainter {
  const WorldPainter({required this.car});

  final Car car;

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = const Color(0xFFDCDCDC);

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    car.paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant WorldPainter oldDelegate) {
    return true; // TODO(matej): Fix oldDelegate.car != car check
  }
}
