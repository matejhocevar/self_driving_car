import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:self_driving_car/world.dart';

void main() {
  debugRepaintRainbowEnabled = true;
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      showPerformanceOverlay: true,
      home: Container(
        color: Colors.grey,
        child: const Center(
          child: World(),
        ),
      ),
    );
  }
}
