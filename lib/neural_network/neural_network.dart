import 'dart:convert';
import 'dart:math' as math;

import '../utils/math.dart';
import 'level.dart';

class NeuralNetwork {
  NeuralNetwork({
    required this.neuronCounts,
  }) {
    for (int i = 0; i < neuronCounts.length - 1; i++) {
      levels.add(
        Level(
          inputCount: neuronCounts[i],
          outputCount: neuronCounts[i + 1],
        ),
      );
    }
  }

  final List<int> neuronCounts;
  List<Level> levels = [];

  static List<double> feedForward(givenInputs, NeuralNetwork network) {
    var outputs = Level.feedForward(givenInputs, network.levels.first);

    for (int i = 1; i < network.levels.length; i++) {
      outputs = Level.feedForward(outputs, network.levels[i]);
    }

    return outputs;
  }

  static NeuralNetwork mutate(NeuralNetwork network, {double amount = 1.0}) {
    network.levels.forEach((Level l) {
      for (int i = 0; i < l.biases.length; i++) {
        l.biases[i] = lerp(
          l.biases[i],
          math.Random().nextDouble() * 2 - 1,
          amount,
        );
      }

      for (int i = 0; i < l.weights.length; i++) {
        for (int j = 0; j < l.weights[i].length; j++) {
          l.weights[i][j] = lerp(
            l.weights[i][j],
            math.Random().nextDouble() * 2 - 1,
            amount,
          );
        }
      }
    });

    return network;
  }

  @override
  String toString() {
    Map<String, dynamic> json = {
      'neuronCounts': neuronCounts,
      'levels': [...levels.map((l) => l.toJSON())],
    };
    return jsonEncode(json);
  }

  static NeuralNetwork fromString(String str) {
    final json = jsonDecode(str);

    List<Level> levels = (json['levels'] as List)
        .map((l) => Level.fromJSON(l as Map<String, dynamic>))
        .toList();

    return NeuralNetwork(neuronCounts: List<int>.from(json['neuronCounts']))
      ..levels = levels;
  }
}
