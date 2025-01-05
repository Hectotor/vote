import 'package:flutter/material.dart';

class CommentField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;

  const CommentField({
    super.key,
    this.controller,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
          bottom: 8.0), // Réduit la marge, uniquement en bas
      width: 350, // Limite la largeur
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: TextFormField(
        controller: controller,
        minLines: 1,
        maxLines: 2,
        maxLength: 35, // Limite de 30 caractères
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'AvenirNext',
          fontWeight: FontWeight.w900,
          fontSize: 26, // Taille augmentée
        ),
        decoration: InputDecoration(
          hintText: hintText ?? 'Texte ici...',
          hintStyle: const TextStyle(
            fontFamily: 'AvenirNext',
            fontWeight: FontWeight.w600,
            fontSize: 26,
          ),
          border: InputBorder.none,
          //contentPadding: const EdgeInsets.all(16.0),
          counterText: '', // Cache le compteur de caractères
        ),
      ),
    );
  }
}
