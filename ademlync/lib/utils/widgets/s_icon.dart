import 'package:flutter/material.dart';

class SIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? color;

  const SIcon(this.icon, {super.key, this.size = 24.0, this.color});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 1.3,
      child: Icon(icon, size: size, color: color),
    );
  }
}
