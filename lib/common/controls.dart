import 'package:flutter/services.dart';

enum ControlType { unknown, keys, dummy, AI }

class Controls {
  Controls({
    this.type = ControlType.dummy,
    this.forward = false,
    this.left = false,
    this.right = false,
    this.reverse = false,
  }) {
    switch (type) {
      case ControlType.dummy:
        {
          forward = true;
          break;
        }
      default:
        break;
    }
  }

  ControlType type;
  bool forward;
  bool left;
  bool right;
  bool reverse;

  void onKeyEvent(RawKeyEvent event) {
    bool isKeyDown = event is RawKeyDownEvent;

    Map<LogicalKeyboardKey, Function> keyActions = {
      LogicalKeyboardKey.arrowLeft: () => left = isKeyDown,
      LogicalKeyboardKey.keyA: () => left = isKeyDown,
      LogicalKeyboardKey.arrowRight: () => right = isKeyDown,
      LogicalKeyboardKey.keyD: () => right = isKeyDown,
      LogicalKeyboardKey.arrowUp: () => forward = isKeyDown,
      LogicalKeyboardKey.keyW: () => forward = isKeyDown,
      LogicalKeyboardKey.arrowDown: () => reverse = isKeyDown,
      LogicalKeyboardKey.keyS: () => reverse = isKeyDown,
    };

    if (keyActions.containsKey(event.logicalKey)) {
      keyActions[event.logicalKey]!();
      // print('${isKeyDown ? 'Key down' : 'Key up'}: ${event.logicalKey}');
    }
  }

  @override
  bool operator ==(Object other) =>
      other is Controls &&
      forward == other.forward &&
      left == other.left &&
      right == other.right &&
      reverse == other.reverse;

  @override
  int get hashCode =>
      forward.hashCode + left.hashCode + right.hashCode + reverse.hashCode;

  @override
  String toString() {
    return 'Controls(forward: $forward, left: $left, right: $right, reverse: $reverse)';
  }
}
