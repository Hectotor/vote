import 'package:flutter/material.dart';

class FloatingPollButton extends StatelessWidget {
  final VoidCallback onPressed;

  const FloatingPollButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(Icons.poll),
      splashRadius: 24, // Optionnel : ajuster le rayon de l'animation de splash
      style: IconButton.styleFrom(
        side: BorderSide.none,
      ),
    );
  }
}
