import 'package:flutter/material.dart';

import '../common/primitives/point.dart';
import '../common/primitives/segment.dart';
import 'graph.dart';

class VirtualWorld extends StatefulWidget {
  const VirtualWorld({super.key});

  @override
  State<VirtualWorld> createState() => _VirtualWorldState();
}

class _VirtualWorldState extends State<VirtualWorld> {
  late Graph graph;

  @override
  void initState() {
    super.initState();

    const Point p1 = Point(200, 200);
    const Point p2 = Point(500, 200);
    const Point p3 = Point(400, 400);
    const Point p4 = Point(100, 300);

    const Segment s1 = Segment(p1, p2);
    const Segment s2 = Segment(p1, p3);
    const Segment s3 = Segment(p1, p4);
    const Segment s4 = Segment(p2, p3);

    graph = Graph(
      points: [p1, p2, p3, p4],
      segments: [s1, s2, s3, s4],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: MediaQuery.sizeOf(context).width,
          height: MediaQuery.sizeOf(context).height,
          child: CustomPaint(
            painter: VirtualWorldPainter(
              graph: graph,
            ),
          ),
        ),
        // Positioned(
        //   bottom: VirtualWorldSettings.controlsMargin,
        //   child: Center(
        //     child: Toolbar(
        //       size: VirtualWorldSettings.controlsSize,
        //       backgroundColor: VirtualWorldSettings.controlsBackgroundColor,
        //       borderRadius: VirtualWorldSettings.controlsRadius,
        //       children: [
        //         const Spacer(),
        //         IconButton(
        //           icon: const Icon(Icons.bookmark_add_outlined),
        //           iconSize: 20,
        //           tooltip: 'Add random Point',
        //           color: Colors.white,
        //           onPressed: _addRandomPoint,
        //         ),
        //         const Spacer(),
        //       ],
        //     ),
        //   ),
        // ),
      ],
    );
  }
}

class VirtualWorldPainter extends CustomPainter {
  const VirtualWorldPainter({required this.graph});

  final Graph graph;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.grey,
    );

    graph.paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant VirtualWorldPainter oldDelegate) =>
      oldDelegate.graph != graph;
}
