import 'dart:convert';

import 'package:flutter/material.dart';

import '../../common/primitives/point.dart';
import '../../common/primitives/polygon.dart';
import '../../utils/color.dart';
import '../../utils/math.dart';
import 'street_furniture.dart';

class Building extends CustomPainter implements StreetFurniture {
  Building(
    this.polygon, {
    this.height = 120,
    this.hasRoof = true,
    this.sideColor = const Color(0xffffffff),
    this.sideBorderColor = const Color(0xffaaaaaa),
    this.roofColor = const Color(0xffd44444),
    this.roofBorderColor = const Color(0xffd44444),
  }) {
    base = polygon;
  }

  final Polygon polygon;
  final double height;
  final bool hasRoof;
  final Color sideColor;
  final Color sideBorderColor;
  final Color roofColor;
  final Color roofBorderColor;

  @override
  late Polygon base;

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
        [base.points[i], base.points[nextI], topPoints[nextI], topPoints[i]],
      );
      sides.add(side);
    }

    sides.sort(
      (a, b) =>
          b.distanceToPoint(viewPoint!).compareTo(a.distanceToPoint(viewPoint)),
    );

    List<Polygon> roofPolygons = [];
    if (hasRoof) {
      // Roof
      List<Point> baseMidpoints = [
        average(base.points[0], base.points[1]),
        average(base.points[2], base.points[3]),
      ];

      List<Point> topMidpoints = baseMidpoints
          .map((p) => getFake3DPoint(p, viewPoint!, height))
          .toList();

      roofPolygons = [
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

      roofPolygons.sort((a, b) => b
          .distanceToPoint(viewPoint!)
          .compareTo(a.distanceToPoint(viewPoint)));
    }

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
      lineWidth: hasRoof ? 6 : 0,
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

  @override
  String toString() {
    Map<String, dynamic> json = {
      'polygon': polygon.points.map((p) => p.toJSON()).toList(),
      'height': height,
      'side_color': sideColor.toString(),
      'side_border_color': sideBorderColor.toString(),
      'roof_color': roofColor.toString(),
      'roof_border_color': roofBorderColor.toString(),
    };
    return jsonEncode(json);
  }

  static Building fromString(String str) {
    final json = jsonDecode(str);

    List<Point> polygonPoints = (json['polygon'] as List<dynamic>)
        .map((p) => Point.fromJSON(List<double>.from(p)))
        .toList();
    Polygon polygon = Polygon(polygonPoints);

    return Building(
      polygon,
      sideColor: (json['side_color'] as String).toColor(),
      sideBorderColor: (json['side_border_color'] as String).toColor(),
      roofColor: (json['roof_color'] as String).toColor(),
      roofBorderColor: (json['roof_border_color'] as String).toColor(),
    );
  }
}
