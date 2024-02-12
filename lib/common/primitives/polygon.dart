import 'package:flutter/material.dart';
import 'package:self_driving_car/utils/math.dart';

import '../../utils/canvas.dart';
import 'point.dart';
import 'position.dart';
import 'segment.dart';

class Polygon extends CustomPainter {
  Polygon(this.points) {
    segments = [];
    for (int i = 1; i <= points.length; i++) {
      segments.add(Segment(points[i - 1], points[i % points.length]));
    }
  }

  final List<Point> points;
  late List<Segment> segments;

  static List<Segment> union(List<Polygon> polygons) {
    Polygon.multiBreak(polygons);

    List<Segment> keptSegments = [];
    for (int i = 0; i < polygons.length; i++) {
      for (Segment s in polygons[i].segments) {
        bool keep = true;
        for (int j = 0; j < polygons.length; j++) {
          if (i != j) {
            if (polygons[j].containsSegment(s)) {
              keep = false;
              break;
            }
          }
        }

        if (keep) {
          keptSegments.add(s);
        }
      }
    }
    return keptSegments;
  }

  static void multiBreak(List<Polygon> polygons) {
    for (int i = 0; i < polygons.length - 1; i++) {
      for (int j = i + 1; j < polygons.length; j++) {
        Polygon.breakSegments(polygons[i], polygons[j]);
      }
    }
  }

  static void breakSegments(Polygon p1, Polygon p2) {
    List<Segment> seg1 = p1.segments;
    List<Segment> seg2 = p2.segments;

    for (int i = 0; i < seg1.length; i++) {
      for (int j = 0; j < seg2.length; j++) {
        Position? int = getIntersection(
          seg1[i].p1.offset,
          seg1[i].p2.offset,
          seg2[j].p1.offset,
          seg2[j].p2.offset,
        );

        if (int != null && int.offset != 1 && int.offset != 0) {
          Point point = Point.fromOffset(int.position);

          Point aux = seg1[i].p2;
          seg1[i].p2 = point;
          seg1.insert(i + 1, Segment(point, aux));
          aux = seg2[j].p2;
          seg2[j].p2 = point;
          seg2.insert(j + 1, Segment(point, aux));
        }
      }
    }
  }

  bool containsSegment(Segment s) {
    Point midPoint = average(s.p1, s.p2);
    return containsPoint(midPoint);
  }

  bool containsPoint(Point p) {
    Point outerPoint = Point(-10000, -10000);

    int intersections = 0;
    for (Segment s in segments) {
      Position? hit = getIntersection(
        outerPoint.offset,
        p.offset,
        s.p1.offset,
        s.p2.offset,
      );
      if (hit != null) {
        intersections++;
      }
    }

    return intersections % 2 == 1;
  }

  void paintSegments(Canvas canvas, Size size) {
    for (Segment s in segments) {
      s.paint(canvas, size, color: getRandomColor(), width: 5);
    }
  }

  @override
  void paint(
    Canvas canvas,
    Size size, {
    Color stroke = Colors.transparent,
    double lineWidth = 2,
    Color fill = Colors.blue,
  }) {
    if (points.isNotEmpty) {
      Paint fillPaint = Paint()
        ..color = fill
        ..style = PaintingStyle.fill
        ..strokeWidth = lineWidth;

      Paint marginPaint = Paint()
        ..color = fill
        ..style = PaintingStyle.stroke
        ..strokeWidth = lineWidth;

      Paint strokePaint = Paint()
        ..color = stroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      Path path = Path();
      path.moveTo(points[0].x, points[0].y);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].x, points[i].y);
      }
      path.close();

      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, marginPaint);
      canvas.drawPath(path, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant Polygon oldDelegate) => true;
}
