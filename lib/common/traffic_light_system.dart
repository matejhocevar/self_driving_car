import '../virtual_world/markings/traffic_light.dart';
import 'primitives/point.dart';

class TrafficLightSystem {
  TrafficLightSystem(
    this.center, {
    this.lights = const [],
    this.greenDuration = 2,
    this.yellowDuration = 1,
    this.redDuration = 1,
  });

  final Point center;
  final List<TrafficLight> lights;
  final int greenDuration;
  final int yellowDuration;
  final int redDuration;

  int get ticks => lights.length * (greenDuration + yellowDuration);

  bool get lightsNotWorking => lights.length < 2;
}
