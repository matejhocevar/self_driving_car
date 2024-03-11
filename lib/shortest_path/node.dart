import '../common/primitives/point.dart';

class Node {
  Node(this.point) {
    visited = false;
    distance = double.infinity;
  }

  final Point point;
  late bool visited;
  late double distance;
  Node? prev;

  @override
  String toString() => '$point (visited: $visited | distance: $distance)';
}
