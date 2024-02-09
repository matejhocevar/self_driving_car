import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'infinity_road/infinity_road.dart';

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
      showPerformanceOverlay: false,
      home: Material(
        child: Container(
          color: Colors.grey,
          child: const InfinityRoad(),
        ),
      ),
    );
  }
}
