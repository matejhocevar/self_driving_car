import '../common/primitives/point.dart';
import '../common/primitives/segment.dart';
import '../virtual_world/graph.dart';
import 'node.dart';
import 'shortest_path_algorithm.dart';

class DijkstraAlgorithm implements ShortestPathAlgorithm {
  @override
  List<Point> findShortestPath(Graph graph, Point start, Point end) {
    List<Node> nodes = graph.points.map((p) => Node(p)).toList();

    final Node startNode = nodes.firstWhere((n) => n.point == start);
    final Node endNode = nodes.firstWhere((n) => n.point == end);

    Node currentNode = startNode;
    currentNode.distance = 0;

    while (!endNode.visited) {
      final segments = graph.segments.where(
        (s) => s.includes(currentNode.point),
      );
      for (Segment s in segments) {
        Point? point;
        if (s.oneWay) {
          point = s.p1 == currentNode.point ? s.p1 : null;
        } else {
          point = s.p1 == currentNode.point ? s.p2 : s.p1;
        }
        if (point != null) {
          final otherNode = nodes.firstWhere((n) => n.point == point);
          if (currentNode.distance + s.length() < otherNode.distance) {
            otherNode.distance = currentNode.distance + s.length();
            otherNode.prev = currentNode;
          }
        }
      }
      currentNode.visited = true;

      final unvisited = nodes.where((n) => !n.visited);
      if (unvisited.isNotEmpty) {
        double minDistance = unvisited.first.distance;
        currentNode = unvisited.first;
        for (Node node in unvisited) {
          if (node.distance < minDistance) {
            minDistance = node.distance;
            currentNode = node;
          }
        }
      }
    }

    List<Point> path = [];
    currentNode = endNode;
    while (currentNode.prev != null) {
      path.insert(0, currentNode.point);
      currentNode = currentNode.prev!;
    }
    path.insert(0, currentNode.point);

    return path;
  }
}
