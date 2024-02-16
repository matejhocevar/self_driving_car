import 'package:flutter/material.dart';

class Toolbar extends StatelessWidget {
  const Toolbar({
    super.key,
    this.direction = Axis.horizontal,
    this.size = const Size(250, 25),
    this.backgroundColor = Colors.black87,
    this.borderRadius = const Radius.circular(6),
    this.children = const [],
  });

  final Axis direction;
  final Size size;
  final Color backgroundColor;
  final Radius borderRadius;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final padding = direction == Axis.vertical
        ? const EdgeInsets.symmetric(vertical: 8)
        : const EdgeInsets.symmetric(horizontal: 8);

    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.all(borderRadius),
      ),
      padding: padding,
      child: Flex(
        crossAxisAlignment: CrossAxisAlignment.center,
        direction: direction,
        children: children,
      ),
    );
  }
}
