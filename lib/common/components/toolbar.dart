import 'package:flutter/material.dart';

class Toolbar extends StatelessWidget {
  const Toolbar({
    super.key,
    this.size = const Size(250, 25),
    this.backgroundColor = Colors.black87,
    this.borderRadius = const Radius.circular(6),
    this.children = const [],
  });

  final Size size;
  final Color backgroundColor;
  final Radius borderRadius;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.all(borderRadius),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: children,
      ),
    );
  }
}
