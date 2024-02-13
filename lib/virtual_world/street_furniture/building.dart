import 'package:flutter/material.dart';

import '../../common/primitives/point.dart';
import '../../common/primitives/polygon.dart';
import '../../utils/math.dart';
import 'street_furniture.dart';

class Building extends CustomPainter implements StreetFurniture {
  const Building(
    this.polygon, {
    this.heightCoef = 0.3,
  });

  final Polygon polygon;
  final double heightCoef;

  @override
  Polygon get base => polygon;

  @override
  void paint(
    Canvas canvas,
    Size size, {
    Point? viewPoint,
  }) {
    viewPoint ??= Point(0, 0);
    final topPoints = base.points
        .map(
          (p) => add(
            p,
            scale(subtract(p, viewPoint!), heightCoef),
          ),
        )
        .toList();

    Polygon ceiling = Polygon(topPoints);

    List<Polygon> sides = [];
    for (int i = 0; i < base.points.length; i++) {
      int nextI = (i + 1) % base.points.length;
      Polygon side = Polygon(
          [base.points[i], base.points[nextI], topPoints[nextI], topPoints[i]]);
      sides.add(side);
    }

    sides.sort(
      (a, b) =>
          b.distanceToPoint(viewPoint!).compareTo(a.distanceToPoint(viewPoint)),
    );

    base.paint(
      canvas,
      size,
      fill: Colors.white,
      stroke: const Color(0xffaaaaaa),
    );

    for (Polygon side in sides) {
      side.paint(
        canvas,
        size,
        fill: Colors.white,
        stroke: const Color(0xffaaaaaa),
      );
    }

    ceiling.paint(
      canvas,
      size,
      fill: Colors.white,
      stroke: const Color(0xffaaaaaa),
    );
  }

  @override
  bool shouldRepaint(covariant Building oldDelegate) =>
      polygon != oldDelegate.polygon || heightCoef != oldDelegate.heightCoef;
}
