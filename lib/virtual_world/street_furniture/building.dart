import 'package:flutter/material.dart';

import '../../common/primitives/point.dart';
import '../../common/primitives/polygon.dart';
import '../../utils/math.dart';
import 'street_furniture.dart';

class Building extends CustomPainter implements StreetFurniture {
  const Building(
    this.polygon, {
    this.height = 120,
    this.sideColor = const Color(0xffffffff),
    this.sideBorderColor = const Color(0xffaaaaaa),
    this.roofColor = const Color(0xffd44444),
    this.roofBorderColor = const Color(0xffd44444),
  });

  final Polygon polygon;
  final double height;
  final Color sideColor;
  final Color sideBorderColor;
  final Color roofColor;
  final Color roofBorderColor;

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
        .map((p) => getFake3DPoint(p, viewPoint!, height * 0.6))
        .toList();

    // Ceiling
    Polygon ceiling = Polygon(topPoints);

    // Sides
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

    // Roof
    List<Point> baseMidpoints = [
      average(base.points[0], base.points[1]),
      average(base.points[2], base.points[3]),
    ];

    List<Point> topMidpoints = baseMidpoints
        .map((p) => getFake3DPoint(p, viewPoint!, height))
        .toList();

    List<Polygon> roofPolygons = [
      Polygon([
        ceiling.points[0],
        ceiling.points[3],
        topMidpoints[1],
        topMidpoints[0],
      ]),
      Polygon([
        ceiling.points[2],
        ceiling.points[1],
        topMidpoints[0],
        topMidpoints[1],
      ]),
    ];

    roofPolygons.sort((a, b) =>
        b.distanceToPoint(viewPoint!).compareTo(a.distanceToPoint(viewPoint)));

    base.paint(
      canvas,
      size,
      fill: sideColor,
      stroke: Colors.black87.withOpacity(0.2),
      lineWidth: 20,
    );

    for (Polygon side in sides) {
      side.paint(
        canvas,
        size,
        fill: sideColor,
        stroke: sideBorderColor,
      );
    }

    ceiling.paint(
      canvas,
      size,
      fill: sideColor,
      stroke: sideBorderColor,
      lineWidth: 6,
    );

    for (Polygon roof in roofPolygons) {
      roof.paint(
        canvas,
        size,
        fill: roofColor,
        stroke: roofBorderColor,
        strokeJoin: StrokeJoin.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant Building oldDelegate) =>
      polygon != oldDelegate.polygon || height != oldDelegate.height;
}