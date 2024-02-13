import 'package:flutter/material.dart';

import '../../common/primitives/polygon.dart';

abstract class Marking {
  late Polygon polygon;

  void paint(Canvas canvas, Size size);
}
