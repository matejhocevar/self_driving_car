import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../common/primitives/point.dart';
import '../../common/primitives/polygon.dart';
import '../../utils/math.dart';
import 'street_furniture.dart';

class Tree extends CustomPainter implements StreetFurniture {
  Tree(
    this.center,
    this.radius, {
    this.height = 200,
    this.layers = 7,
    Polygon? base,
  }) {
    this.base = base ?? _generateLevel(center, radius);
  }

  final Point center;
  final double radius;
  final double height;
  final int layers;
  @override
  late Polygon base;

  Polygon _generateLevel(Point point, double radius) {
    List<Point> points = [];
    for (double a = 0; a < math.pi * 2; a += math.pi / 16) {
      double random =
          math.pow(math.cos(((a + center.x) * radius) % 17), 2).toDouble();
      double noisyRadius = radius * lerp(0.5, 1, random);
      points.add(translate(point, a, noisyRadius));
    }
    return Polygon(points);
  }

  @override
  void paint(
    Canvas canvas,
    Size size, {
    Point? viewPoint,
  }) {
    viewPoint ??= Point(0, 0);
    Point top = getFake3DPoint(center, viewPoint, height);

    for (int layer = 0; layer < layers; layer++) {
      final t = layer / (layers - 1);
      final point = lerp2D(center, top, t);
      final color = Color.fromRGBO(30, lerp(50, 200, t).toInt(), 70, 1);
      final levelRadius = lerp(radius, 40, t);

      Polygon polygon = _generateLevel(point, levelRadius);
      polygon.paint(canvas, size, fill: color);
    }
  }

  @override
  bool shouldRepaint(covariant Tree oldDelegate) =>
      center != oldDelegate.center ||
      radius != oldDelegate.radius ||
      layers != oldDelegate.layers ||
      height != oldDelegate.height;

  @override
  String toString() {
    Map<String, dynamic> json = {
      'center': center.toJSON(),
      'radius': radius,
      'height': height,
      'layers': layers,
      'base': base.points.map((p) => p.toJSON()).toList(),
    };
    return jsonEncode(json);
  }

  static Tree fromString(String str) {
    final json = jsonDecode(str);

    Point center = Point.fromJSON(List<double>.from(json['center']));

    List<Point> basePoints = (json['base'] as List<dynamic>)
        .map((p) => Point.fromJSON(List<double>.from(p)))
        .toList();
    Polygon base = Polygon(basePoints);

    return Tree(
      center,
      json['radius'],
      height: json['height'],
      layers: json['layers'],
      base: base,
    );
  }
}
