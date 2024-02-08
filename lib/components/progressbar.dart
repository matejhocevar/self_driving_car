import 'package:flutter/material.dart';

import '../constants/world_settings.dart';
import '../utils/math.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    const BorderRadius borderRadius = BorderRadius.only(
      bottomLeft: WorldSettings.visualisationRadius,
      bottomRight: WorldSettings.visualisationRadius,
    );

    return Stack(
      children: [
        Container(
          height: WorldSettings.visualisationProgressBarSize.height,
          width: WorldSettings.visualisationProgressBarSize.width,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: borderRadius,
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            height: WorldSettings.visualisationProgressBarSize.height,
            width: WorldSettings.visualisationProgressBarSize.width -
                lerp(
                  0,
                  WorldSettings.visualisationProgressBarSize.width,
                  progress,
                ),
            decoration: const BoxDecoration(
              color: WorldSettings.visualisationBackgroundColor,
              borderRadius: borderRadius,
            ),
          ),
        ),
      ],
    );
  }
}
