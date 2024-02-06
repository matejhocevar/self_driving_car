import 'package:flutter/material.dart';

import 'math.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    const BorderRadius borderRadius = BorderRadius.only(
      bottomLeft: Radius.circular(6),
      bottomRight: Radius.circular(6),
    );

    return Stack(
      children: [
        Container(
          height: 4,
          width: 250,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: borderRadius,
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            height: 4,
            width: 250 - lerp(0, 250, progress),
            decoration: const BoxDecoration(
              color: Colors.black87,
              borderRadius: borderRadius,
            ),
          ),
        ),
      ],
    );
  }
}
