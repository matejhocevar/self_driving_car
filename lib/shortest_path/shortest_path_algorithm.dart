import '../common/primitives/point.dart';
import '../virtual_world/graph.dart';

abstract class ShortestPathAlgorithm {
  List<Point> findShortestPath(Graph graph, Point start, Point end);
}
