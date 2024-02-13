import 'package:flutter/material.dart';

class ToolbarIcon extends StatelessWidget {
  const ToolbarIcon({
    super.key,
    required this.icon,
    this.onTap,
    this.tooltip = '',
    this.isActive = false,
  });

  final IconData icon;
  final String tooltip;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: isActive ? Colors.green : Colors.white),
      iconSize: 20,
      tooltip: tooltip,
      color: Colors.white,
      onPressed: onTap,
    );
  }
}
