import 'package:flutter/material.dart';

class BottomAddBloc extends StatelessWidget {
  final bool showPoll;
  final int numberOfPollBlocs;
  final VoidCallback onPressed;

  const BottomAddBloc({
    Key? key,
    required this.showPoll,
    required this.numberOfPollBlocs,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (numberOfPollBlocs >= 4) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,  // Couleur de fond violet sombre
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),  // Bordure subtile
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_circle_outline,
                size: 20,
                color: Colors.white70,  // Icône blanche légèrement transparente
              ),
              const SizedBox(width: 8),
              Text(
                'Ajouter',
                style: TextStyle(
                  color: Colors.white70,  // Texte blanc légèrement transparent
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
