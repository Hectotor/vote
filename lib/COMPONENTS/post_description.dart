import 'package:flutter/material.dart';

class PostDescription extends StatelessWidget {
  final String pseudo;
  final String description;

  const PostDescription({
    Key? key,
    required this.pseudo,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Nettoie les sauts de ligne vides et les espaces inutiles
    final cleanedDescription = description
        .replaceAll(RegExp(r'\n\s*\n'), '\n') // Remplace les lignes vides par un seul saut de ligne
        .trim(); // Supprime les espaces au début et à la fin
    
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            cleanedDescription,
            style: const TextStyle(
              //color: Colors.white,
              fontSize: 18,
            ),
            softWrap: true, // Permet le retour à la ligne sans couper les mots
            overflow: TextOverflow.visible, // Permet au texte de déborder si nécessaire
          ),
        ],
      ),
    );
  }
}
