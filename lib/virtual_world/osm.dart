import 'dart:convert';
import 'dart:math' as math;

import 'package:self_driving_car/common/primitives/envelope.dart';
import 'package:self_driving_car/virtual_world/settings.dart';

import '../common/primitives/point.dart';
import '../common/primitives/polygon.dart';
import '../common/primitives/segment.dart';
import '../utils/math.dart';
import 'graph.dart';
import 'street_furniture/building.dart';
import 'street_furniture/land.dart';
import 'street_furniture/tree.dart';
import 'viewport.dart';
import 'world.dart';

class OSM {
  static Future<World> parse(String str, {required ViewPort viewport}) async {
    try {
      final json = jsonDecode(str);

      // Parse nodes
      List nodes = (json['elements'] as List<dynamic>)
          .where((n) => n['type'] == 'node')
          .toList();

      // Filter ways
      List roadWays = [];
      List buildingWays = [];
      List riverWays = [];
      List landsWays = [];
      for (var el in json['elements'] as List<dynamic>) {
        if (el['type'] == 'way' && el['tags'] != null) {
          if ((el['tags'] as Map<String, dynamic>).containsKey('highway')) {
            roadWays.add(el);
          }

          if ((el['tags'] as Map<String, dynamic>).containsKey('building')) {
            buildingWays.add(el);
          }

          if ((el['tags'] as Map<String, dynamic>).containsKey('waterway')) {
            riverWays.add(el);
          }

          if ((el['tags'] as Map<String, dynamic>).containsKey('natural') ||
              el['tags'].containsKey('landuse')) {
            landsWays.add(el);
          }
        }
      }

      // Calculate geolocation metrics
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
      final width = height * aspectRatio * math.cos(degToRad(maxLat));

      // Parse points
      final allPoints = nodes.map((n) {
        int id = n['id'];
        double lat = n['lat'];
        double lon = n['lon'];

        double y = invLerp(maxLat, minLat, lat) * height;
        double x = invLerp(minLon, maxLon, lon) * width;
        Point point = Point(x, y);
        point.id = id;

        return point;
      }).toList();

      // Parse roads & buildings
      final (points, segments) = _parseRoads(allPoints, roadWays);
      final List<Building> buildings = _parseBuildings(allPoints, buildingWays);
      final List<Envelope> rivers = _parseRivers(allPoints, riverWays);
      final List<Land> lands = _parseLands(allPoints, landsWays);

      viewport.offset = scale(calculateCentroid(allPoints), -1);
      viewport.zoom = VirtualWorldSettings.viewportZoomMax;

      World world = World(
        graph: Graph(points: points, segments: segments),
        viewport: viewport,
        regenerateBuildings: false,
        regenerateTrees: false,
      );

      world.buildings = buildings;
      world.rivers = rivers;

      // Generate trees in [LandType.forest] polygons
      List<Tree> trees = List.empty(growable: true);
      lands.where((l) => l.type == LandType.forest).forEach((l) {
        trees.addAll(
          world.generateTrees(
            polygon: l.polygon,
            allowInMiddleOfNowhere: true,
            density: 1,
          ),
        );
      });

      return world
        ..lands = lands
        ..trees = trees;
    } catch (e, stackTrace) {
      print('Failed to parse OSM data. Check your input');
      print(e);
      print(stackTrace);
    }

    return World(graph: Graph(), viewport: viewport);
  }

  static (List<Point>, List<Segment>) _parseRoads(
      List<Point> allPoints, List ways) {
    List<Segment> segments = [];
    Set<Point> points = <Point>{};

    for (var way in ways) {
      final ids = way['nodes'];
      for (int i = 1; i < ids.length; i++) {
        Point prev = allPoints.firstWhere((p) => p.id == ids[i - 1]);
        Point curr = allPoints.firstWhere((p) => p.id == ids[i]);
        bool oneWay =
            (way['tags'] as Map<String, dynamic>).containsKey('oneway') ||
                way['tags']?['lanes'] == 1;
        segments.add(Segment(prev, curr, oneWay: oneWay));
        points.add(prev);

        if (i == ids.length - 1) {
          points.add(curr);
        }
      }
    }

    return (points.toList(), segments);
  }

  static List<Building> _parseBuildings(List<Point> points, List ways) {
    List<Building> buildings = [];
    for (var way in ways) {
      final ids = way['nodes'];

      List<Point> buildingPoints = [];
      for (int i = 1; i < ids.length; i++) {
        buildingPoints.add(points.firstWhere((p) => p.id == ids[i]));
      }
      buildings.add(
        Building(Polygon(buildingPoints), hasRoof: ids.length < 6),
      );
    }

    return buildings;
  }

  static List<Envelope> _parseRivers(List<Point> allPoints, List ways) {
    List<Envelope> envelopes = [];

    for (var way in ways) {
      final ids = way['nodes'];
      for (int i = 1; i < ids.length; i++) {
        Point prev = allPoints.firstWhere((p) => p.id == ids[i - 1]);
        Point curr = allPoints.firstWhere((p) => p.id == ids[i]);
        Segment s = Segment(prev, curr, oneWay: true);
        envelopes.add(
          Envelope(
            s,
            width: VirtualWorldSettings.riverWidth,
            roundness: VirtualWorldSettings.riverRoundness,
          ),
        );
      }
    }

    return envelopes;
  }

  static List<Land> _parseLands(List<Point> allPoints, List ways) {
    List<Land> lands = [];

    for (var way in ways) {
      final ids = way['nodes'];
      List<Point> points = [];
      for (int i = 0; i < ids.length; i++) {
        Point p = allPoints.firstWhere((p) => p.id == ids[i]);
        points.add(p);
      }

      LandType type = LandType.unknown;
      String? typeKey;
      if ((way['tags'] as Map<String, dynamic>).containsKey('natural')) {
        typeKey = way['tags']['natural'];
      } else if ((way['tags'] as Map<String, dynamic>).containsKey('landuse')) {
        typeKey = way['tags']['landuse'];
      }

      type = switch (typeKey) {
        'water' ||
        'bay' ||
        'spring' ||
        'hot_spring' ||
        'strait' ||
        'wetland' ||
        'basic' ||
        'salt_pond' =>
          LandType.water,
        'meadow' ||
        'grassland' ||
        'hill' ||
        'valley' ||
        'grass' ||
        'village_green' =>
          LandType.green,
        'farmland' || 'paddy' => LandType.farmland,
        'orchard' || 'vineyard' => LandType.orchard,
        'scrub' ||
        'tundra' ||
        'mud' ||
        'cliff' ||
        'dune' ||
        'brownfield' ||
        'landfill' =>
          LandType.tundra,
        'forest' || 'wood' || 'gully' => LandType.forest,
        'beach' ||
        'cape' ||
        'coastline' ||
        'isthmus' ||
        'peninsula' ||
        'shingle' ||
        'shoal' ||
        'sand' =>
          LandType.beach,
        'glacier' ||
        'arete' ||
        'peak' ||
        'winter_sports' ||
        'crevasse' =>
          LandType.snow,
        'rock' || 'sand' || 'saddle' || 'stone' || 'quarry' => LandType.rock,
        'volcano' => LandType.volcano,
        _ => LandType.unknown,
      };

      lands.add(
        Land(Polygon(points), type: type),
      );
    }

    return lands;
  }
}
