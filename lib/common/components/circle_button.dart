import 'package:flutter/material.dart';

class CircleButton extends StatelessWidget {
  const CircleButton({
    super.key,
    required this.icon,
    this.onTap,
    this.color = Colors.black,
    this.backgroundColor = Colors.white,
    this.size = 50,
  });

  final IconData icon;
  final double size;
  final Color color;
  final Color backgroundColor;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: color,
        ),
      ),
    );
  }
}
