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

  late final List<Point> points;
  late final List<Segment> segments;

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
}
