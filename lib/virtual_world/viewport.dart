import 'dart:ui';

import '../common/primitives/point.dart';
import '../utils/math.dart';
import 'settings.dart';

class ViewPort {
  ViewPort({
    required double width,
    required double height,
    this.zoom = 1,
    Point? offset,
  }) {
    center = Point(width / 2, height / 2);
    this.offset = offset ?? scale(center, -1);
  }

  double zoom = 1;
  late Point center;
  late Point offset;
  Map<String, dynamic> drag = {
    'start': Point(0, 0),
    'end': Point(0, 0),
    'offset': Point(0, 0),
    'isActive': false,
  };

  Point getMouse(Point p, {bool subtractDragOffset = false}) {
    Point point = Point(
      (p.x - center.x) * zoom - offset.x,
      (p.y - center.y) * zoom - offset.y,
    );

    return subtractDragOffset ? subtract(point, drag['offset']) : point;
  }

  Point getOffset() {
    return add(offset, drag['offset']);
  }

  void handleZoom(Offset offset) {
    double dir = offset.dy.sign;
    zoom += dir * VirtualWorldSettings.viewportZoomStep;
    zoom = clampDouble(
      zoom,
      VirtualWorldSettings.viewportZoomMin,
      VirtualWorldSettings.viewportZoomMax,
    );
  }

  void handlePanStart(Point p) {
    drag['start'] = getMouse(p);
    drag['isActive'] = true;
  }

  void handlePanUpdate(Point p) {
    if (drag['isActive']) {
      drag['end'] = getMouse(p);
      drag['offset'] = subtract(drag['end'], drag['start']);
    }
  }

  void handlePanEnd() {
    if (drag['isActive']) {
      offset = add(offset, drag['offset']);
      drag = {
        'start': Point(0, 0),
        'end': Point(0, 0),
        'offset': Point(0, 0),
        'isActive': false,
      };
    }
  }
}
