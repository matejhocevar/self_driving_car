import 'dart:convert';

import 'package:flutter/cupertino.dart';

import '../common/primitives/point.dart';
import '../common/primitives/segment.dart';

class Graph extends CustomPainter {
  Graph({
    List<Point> points = const [],
    List<Segment> segments = const [],
  }) {
    this.points = List.from(points, growable: true);
    this.segments = List.from(segments, growable: true);
  }

  late List<Point> points;
  late List<Segment> segments;

  bool tryAddPoint(Point p) {
    if (points.contains(p)) {
      return false;
    }

    points.add(p);
    return true;
  }

  bool tryAddSegment(Segment s) {
    if (segments.contains(s) || s.p1 == s.p2) {
      return false;
    }

    segments.add(s);
    return true;
  }

  void removePoint(Point point) {
    points.removeWhere((p) => p == point);
    segments.removeWhere((s) => s.includes(point));
  }

  void removeSegment(Segment segment) {
    segments.removeWhere((s) => s == segment);
  }

  void dispose() {
    segments.removeWhere((_) => true);
    points.removeWhere((_) => true);
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (Segment s in segments) {
      s.paint(canvas, size);
    }

    for (Point p in points) {
      p.paint(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) =>
      oldDelegate != this;

  String get hash => toString();

  @override
  String toString() {
    Map<String, dynamic> json = {
      'points': points.map((p) => p.toJSON()).toList(),
      'segments': segments.map((s) => s.toJSON()).toList(),
    };
    return jsonEncode(json);
  }

  static Graph fromString(String str) {
    final json = jsonDecode(str);

    List<Point> points = (json['points'] as List<dynamic>)
        .map((p) => Point.fromJSON(List<double>.from(p)))
        .toList();

    List<Segment> segments = (json['segments'] as List<dynamic>).map((s) {
      final [p1x, p1y, p2x, p2y] = List<double>.from(s);
      var p1 = points.firstWhere((Point pp) => pp.x == p1x && pp.y == p1y);
      var p2 = points.firstWhere((Point pp) => pp.x == p2x && pp.y == p2y);
      return Segment(p1, p2);
    }).toList();

    return Graph()
      ..points = points
      ..segments = segments;
  }
}
