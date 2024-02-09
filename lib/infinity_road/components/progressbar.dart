import 'package:flutter/material.dart';

import '../../utils/math.dart';
import '../settings.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    const BorderRadius borderRadius = BorderRadius.only(
      bottomLeft: InfinityRoadSettings.visualisationRadius,
      bottomRight: InfinityRoadSettings.visualisationRadius,
    );

    return Stack(
      children: [
        Container(
          height: InfinityRoadSettings.visualisationProgressBarSize.height,
          width: InfinityRoadSettings.visualisationProgressBarSize.width,
          decoration: BoxDecoration(
            color: progress == 1 ? Colors.green : Colors.white,
            borderRadius: borderRadius,
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            height: InfinityRoadSettings.visualisationProgressBarSize.height,
            width: InfinityRoadSettings.visualisationProgressBarSize.width -
                lerp(
                  0,
                  InfinityRoadSettings.visualisationProgressBarSize.width,
                  progress,
                ),
            decoration: const BoxDecoration(
              color: InfinityRoadSettings.visualisationBackgroundColor,
              borderRadius: borderRadius,
            ),
          ),
        ),
      ],
    );
  }
}
