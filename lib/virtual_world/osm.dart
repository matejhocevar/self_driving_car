import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../common/primitives/point.dart';
import '../common/primitives/segment.dart';
import '../utils/math.dart';
import 'graph.dart';

class OSM {
  static Future<Graph> parse(String str, {required Size size}) async {
    try {
      final json = jsonDecode(str);

      List nodes = (json['elements'] as List<dynamic>)
          .where((n) => n['type'] == 'node')
          .toList();
      List ways = (json['elements'] as List<dynamic>)
          .where((n) => n['type'] == 'way')
          .toList();

      final (points, segments) = _parseRoads(nodes, ways, size);
      return Graph(points: points, segments: segments);
    } catch (e, stackTrace) {
      print('Failed to parse OSM data. Check your input');
      print(e);
      print(stackTrace);
    }

    return Graph();
  }

  static (List<Point>, List<Segment>) _parseRoads(
    List nodes,
    List ways,
    Size size,
  ) {
    size *= 5;
    var latitudes = nodes.map((n) => n['lat'] as double).toList();
    var longitudes = nodes.map((n) => n['lon'] as double).toList();

    final minLat = latitudes.reduce(math.min);
    final maxLat = latitudes.reduce(math.max);
    final minLon = longitudes.reduce(math.min);
    final maxLon = longitudes.reduce(math.max);

    final deltaLat = maxLat - minLat;
    final deltaLon = maxLon - minLon;
    final aspectRatio = deltaLon / deltaLat;
    final height = deltaLat * 111000 * 10;
    final width = size.height * aspectRatio * math.cos(degToRad(maxLat));

    final points = nodes.map((n) {
      int id = n['id'];
      double lat = n['lat'];
      double lon = n['lon'];

      double y = invLerp(maxLat, minLat, lat) * height;
      double x = invLerp(minLon, maxLon, lon) * width;
      Point point = Point(x, y);
      point.id = id;

      return point;
    }).toList();

    List<Segment> segments = [];
    for (var way in ways) {
      final ids = way['nodes'];
      for (int i = 1; i < ids.length; i++) {
        Point prev = points.firstWhere((p) => p.id == ids[i - 1]);
        Point curr = points.firstWhere((p) => p.id == ids[i]);
        bool oneWay =
            (way['tags'] as Map<String, dynamic>).containsKey('oneway') ||
                way['tags']?['lanes'] == 1;
        segments.add(Segment(prev, curr, oneWay: oneWay));
      }
    }

    return (points, segments);
  }
}
