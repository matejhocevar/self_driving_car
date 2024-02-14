import 'package:flutter/material.dart';

extension RGBA on double {
  Color toRGBA() {
    double value = this;
    double opacity = value.abs();
    int r = value < 0 ? 0 : 255;
    int g = r;
    int b = value > 0 ? 0 : 255;

    return Color.fromRGBO(r, g, b, opacity);
  }
}

extension ToColor on String {
  Color toColor() {
    String colorStr = split('(0x')[1].split(')')[0];
    int value = int.parse(colorStr, radix: 16);
    return Color(value);
  }
}
