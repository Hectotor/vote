import 'package:flutter/material.dart';

class VotePercentageBadge extends StatelessWidget {
  final double percentage;
  final double? size;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;

  const VotePercentageBadge({
    Key? key,
    required this.percentage,
    this.size,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
  }) : super(key: key);

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
        child: Text(
          '${percentage.toStringAsFixed(1)}%',
          style: TextStyle(
            color: textColor ?? Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: fontSize ?? 20,
          ),
        ),
      ),
    );
  }
}
