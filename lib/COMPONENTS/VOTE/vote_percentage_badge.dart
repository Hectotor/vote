import 'package:flutter/material.dart';

class VotePercentageBadge extends StatelessWidget {
  final double percentage;
  final double? size;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final bool showHeart;

  const VotePercentageBadge({
    Key? key,
    required this.percentage,
    this.size,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.showHeart = false,
  }) : super(key: key);
  
  // Retourne une couleur basée sur le pourcentage
  Color _getColorByPercentage(double p) {
    if (p >= 75) return Color(0xFF4CAF50); // Vert
    if (p >= 50) return Color(0xFFFFA726); // Orange
    return Color(0xFFEF5350);              // Rouge doux
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.black54,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                color: showHeart ? _getColorByPercentage(percentage) : (textColor ?? Colors.white),
                fontWeight: FontWeight.bold,
                fontSize: fontSize ?? 20,
              ),
            ),
            if (showHeart) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.favorite,
                color: _getColorByPercentage(percentage),
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
