import 'package:flutter/material.dart';

class Toolbar extends StatelessWidget {
  const Toolbar({
    super.key,
    this.children = const [],
    this.size = const Size(250, 25),
  });

  final Size size;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: children,
      ),
    );
  }
}
