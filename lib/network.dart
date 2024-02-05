import 'dart:math' as math;

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
}

class Level {
  Level({
    required this.inputCount,
    required this.outputCount,
  }) {
    inputs = List.generate(inputCount, (_) => 0);
    outputs = List.generate(outputCount, (_) => 0);
    biases = List.generate(outputCount, (_) => 0);
    weights = List.generate(inputCount, (index) => []);

    for (int i = 0; i < inputCount; i++) {
      weights[i] = List.generate(outputCount, (_) => 0);
    }

    Level.randomize(this);
  }

  final int inputCount;
  final int outputCount;

  List<double> inputs = [];
  List<double> outputs = [];
  List<double> biases = [];
  List<List<double>> weights = [];

  static void randomize(Level level) {
    for (int i = 0; i < level.inputs.length; i++) {
      for (int j = 0; j < level.outputs.length; j++) {
        level.weights[i][j] = math.Random().nextDouble() * 2 - 1;
      }
    }

    for (int i = 0; i < level.biases.length; i++) {
      level.biases[i] = math.Random().nextDouble() * 2 - 1;
    }
  }

  static List<double> feedForward(List<double> givenInputs, Level level) {
    for (int i = 0; i < level.inputs.length; i++) {
      level.inputs[i] = givenInputs[i];
    }

    for (int i = 0; i < level.outputs.length; i++) {
      double sum = 0;

      for (int j = 0; j < level.inputs.length; j++) {
        sum += level.inputs[j] * level.weights[j][i];
      }

      if (sum > level.biases[i]) {
        level.outputs[i] = 1;
      } else {
        level.outputs[i] = 0;
      }
    }

    return level.outputs;
  }
}
