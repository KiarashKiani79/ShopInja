import 'package:flutter/material.dart';

import '../models/my_colors.dart';

class GradientIcon extends StatelessWidget {
  final IconData icon;
  final Color startColor;
  final Color endColor;
  final double size;

  const GradientIcon({
    super.key,
    required this.icon,
    this.startColor = AppColors.turquoise,
    this.endColor = AppColors.deepSkyBlue,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    LinearGradient gradient = LinearGradient(
      colors: [startColor, endColor],
      begin: Alignment.centerRight,
      end: Alignment.centerLeft,
    );

    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return gradient.createShader(bounds);
      },
      child: Icon(
        icon,
        color: Colors.white,
        size: size,
      ),
    );
  }
}
