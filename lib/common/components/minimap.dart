import 'package:flutter/material.dart';
import 'package:self_driving_car/virtual_world/settings.dart';

import '../../utils/math.dart';
import '../../virtual_world/world.dart';
import '../primitives/envelope.dart';
import '../primitives/point.dart';
import '../primitives/polygon.dart';
import '../primitives/segment.dart';
import 'circle_button.dart';

class MiniMap extends StatefulWidget {
  const MiniMap({super.key, required this.world, this.radius = 300});

  final World world;
  final double radius;

  @override
  State<MiniMap> createState() => _MiniMapState();
}

class _MiniMapState extends State<MiniMap> {
  double scaler = VirtualWorldSettings.minimapScalerDefault;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: widget.radius,
          height: widget.radius,
          child: CustomPaint(
            size: Size.fromRadius(widget.radius),
            painter: MiniMapPainter(
              world: widget.world,
              radius: widget.radius,
              scaler: scaler,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 24,
          child: CircleButton(
            icon: Icons.remove,
            onTap: () {
              setState(() {
                scaler *= VirtualWorldSettings.minimapScalerIncreaseFactor;
              });
            },
            size: 32,
            color: Colors.white,
            backgroundColor: Colors.black87,
          ),
        ),
        Positioned(
          top: 32,
          right: 0,
          child: CircleButton(
            icon: Icons.add,
            onTap: () {
              setState(() {
                scaler *= VirtualWorldSettings.minimapScalerDecreaseFactor;
              });
            },
            size: 32,
            color: Colors.white,
            backgroundColor: VirtualWorldSettings.minimapBorderColor,
          ),
        ),
      ],
    );
  }
}

class MiniMapPainter extends CustomPainter {
  const MiniMapPainter(
      {required this.world, this.radius = 300, this.scaler = 0.05});

  final World world;
  final double radius;
  final double scaler;

  @override
  void paint(Canvas canvas, Size size) {
    final viewPoint = scale(world.viewport.getOffset(), -1);
    Point scaledViewPoint = scale(viewPoint, -scaler);

    canvas.drawCircle(
      Offset(radius / 2, radius / 2),
      radius / 2 + VirtualWorldSettings.minimapBorderWidth,
      Paint()..color = VirtualWorldSettings.minimapBorderColor,
    );

    canvas.drawCircle(
      Offset(radius / 2, radius / 2),
      radius / 2,
      Paint()..color = VirtualWorldSettings.surfaceColor,
    );

    canvas.clipRRect(
      RRect.fromRectAndRadius(
        Rect.fromCircle(
          center: Offset(radius / 2, radius / 2),
          radius: radius / 2,
        ),
        Radius.circular(radius / 2),
      ),
    );

    canvas.save();

    canvas.translate(
      radius / 2 + scaledViewPoint.x,
      radius / 2 + scaledViewPoint.y,
    );
    canvas.scale(scaler, scaler);

    // Rivers
    for (Envelope e in world.rivers) {
      e.paint(
        canvas,
        size,
        fill: VirtualWorldSettings.riverColor,
        lineWidth: VirtualWorldSettings.riverMargin,
      );
    }

    // Sea and lakes
    for (Polygon p in world.seaAndLakes) {
      p.paint(
        canvas,
        size,
        fill: VirtualWorldSettings.riverColor,
        lineWidth: VirtualWorldSettings.riverMargin,
      );
    }

    // Roads
    for (Segment s in world.graph.segments) {
      s.paint(
        canvas,
        size,
        color: VirtualWorldSettings.minimapRoadColor,
        width: VirtualWorldSettings.minimapRoadWidthFactor * 1 / scaler,
      );
    }

    canvas.restore();
    Point(radius / 2, radius / 2).paint(
      canvas,
      size,
      color: VirtualWorldSettings.minimapCarIndicatorColor,
      radius: VirtualWorldSettings.minimapCarIndicatorRadius,
      outline: VirtualWorldSettings.minimapCarIndicatorOutline,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
