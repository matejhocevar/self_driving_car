import 'package:flutter/material.dart';

import 'virtual_world/app.dart';

void main() {
  // debugRepaintRainbowEnabled = true;
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
          child: const App(),
        ),
      ),
    );
  }
}
