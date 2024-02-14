import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:self_driving_car/common/constants/vehicles.dart';

import '../../common/primitives/envelope.dart';
import '../../common/primitives/point.dart';
import '../../common/primitives/polygon.dart';
import '../../common/primitives/segment.dart';
import '../../utils/math.dart';
import 'crossing.dart';
import 'parking.dart';
import 'start.dart';
import 'stop.dart';
import 'target.dart';
import 'traffic_light.dart';
import 'yield.dart';

enum MarkingType {
  unknown,
  crossing,
  parking,
  start,
  stop,
  target,
  trafficLight,
  yield,
}

class Marking extends CustomPainter {
  Marking(
    this.type,
    this.center,
    this.directionVector, {
    this.width = 20,
    this.height = 10,
    Segment? support,
    Polygon? polygon,
    List<Segment>? borders,
    Map<String, dynamic>? extras,
  }) {
    this.support = support ??
        Segment(
          translate(center, angle(directionVector), height / 2),
          translate(center, angle(directionVector), -height / 2),
        );
    this.polygon = polygon ?? Envelope(this.support, width: width).polygon;
    this.borders = borders ?? const [];
    this.extras = extras ?? const {};
  }

  final MarkingType type;
  final Point center;
  final Point directionVector;
  final double width;
  final double height;

  late Segment support;
  late Polygon polygon;
  late List<Segment> borders;
  late Map<String, dynamic> extras;

  @override
  void paint(Canvas canvas, Size size) {
    polygon.paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant Marking oldDelegate) => true;

  @override
  String toString() {
    Map<String, dynamic> json = {
      'type': type.name,
      'center': center.toJSON(),
      'direction_vector': directionVector.toJSON(),
      'width': width,
      'height': height,
      'support': support.toJSON(),
      'polygon': polygon.points.map((p) => p.toJSON()).toList(),
      'borders': borders.map((s) => s.toJSON()).toList(),
      'extras': extras,
    };
    return jsonEncode(json);
  }

  static Marking fromString(String str) {
    final json = jsonDecode(str);

    MarkingType type = MarkingType.values.firstWhere(
      (t) => t.name == json['type'],
      orElse: () => MarkingType.unknown,
    );

    Point center = Point.fromJSON(List<double>.from(json['center']));
    Point directionVector =
        Point.fromJSON(List<double>.from(json['direction_vector']));
    Segment support = Segment.load(json['support']);

    List<Point> polygonPoints = (json['polygon'] as List<dynamic>)
        .map((p) => Point.fromJSON(List<double>.from(p)))
        .toList();
    Polygon polygon = Polygon(polygonPoints);

    List<Segment> borders =
        (json['borders'] as List<dynamic>).map((s) => Segment.load(s)).toList();

    double width = json['width'];
    double height = json['height'];

    Marking marking = Marking(
      type,
      center,
      directionVector,
      width: width,
      height: height,
      support: support,
      polygon: polygon,
      borders: borders,
    );

    return switch (type) {
      MarkingType.crossing => Crossing(
          center,
          directionVector,
          width: width,
          height: height,
        ),
      MarkingType.parking => Parking(
          center,
          directionVector,
          width: width,
          height: height,
        ),
      MarkingType.start => Start(
          center,
          directionVector,
          vehicles.firstWhere((v) => v.name == json['extras']['vehicle']),
          width: width,
          height: height,
        ),
      MarkingType.stop => Stop(
          center,
          directionVector,
          width: width,
          height: height,
        ),
      MarkingType.target => Target(
          center,
          directionVector,
          width: width,
          height: height,
        ),
      MarkingType.trafficLight => TrafficLight(
          center,
          directionVector,
          width: width,
          height: height,
        ),
      MarkingType.yield => Yield(
          center,
          directionVector,
          width: width,
          height: height,
        ),
      MarkingType.unknown => marking,
    };
  }
}
