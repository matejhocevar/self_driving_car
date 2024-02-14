import 'package:flutter/material.dart';

import '../../common/primitives/point.dart';
import '../../common/primitives/polygon.dart';

abstract class StreetFurniture {
  late Polygon base;

  void paint(
    Canvas canvas,
    Size size, {
    Point? viewPoint,
  });
}
