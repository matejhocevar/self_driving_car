import 'dart:math' as math;

import 'package:flutter/material.dart';

class Road {
  Road({
    required this.x,
    required this.width,
    this.laneCount = 3,
  }) {
    left = x - width / 2;
    right = x + width / 2;
    borders = [
      [Offset(left, top), Offset(left, bottom)],
      [Offset(right, top), Offset(right, bottom)],
    ];
  }

  static const double infinity = 10000;

  final double x;
  final double width;
  int laneCount;

  late final double left;
  late final double right;
  late final List<List<Offset>> borders;

  final double top = -Road.infinity;
  final double bottom = Road.infinity;

  Road copyWith({
    double? x,
    double? width,
    int? laneCount,
  }) {
    return Road(
      x: x ?? this.x,
      width: width ?? this.width,
      laneCount: laneCount ?? this.laneCount,
    );
  }

  double getLaneCenter(int laneIndex) {
    final laneWidth = width / laneCount;
    return left +
        laneWidth / 2 +
        math.min(laneIndex, laneCount - 1) * laneWidth;
  }

  @override
  bool operator ==(Object other) {
    return other is Road &&
        x == other.x &&
        width == other.width &&
        laneCount == other.laneCount;
  }

  @override
  int get hashCode => Object.hash(x, width, laneCount);

  @override
  String toString() {
    return 'Road(x: $x, width: $width, laneCount: $laneCount)';
  }
}
