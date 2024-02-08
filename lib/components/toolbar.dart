import 'package:flutter/material.dart';

import '../constants/world_settings.dart';

class Toolbar extends StatelessWidget {
  const Toolbar({
    super.key,
    this.children = const [],
    this.size = const Size(250, 25),
  });

  final Size size;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: const BoxDecoration(
        color: WorldSettings.visualisationBackgroundColor,
        borderRadius: BorderRadius.all(WorldSettings.visualisationRadius),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: children,
      ),
    );
  }
}
