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
        maxLength: 45, // Limite de 30 caractères
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'AvenirNext',
          fontWeight: FontWeight.w900,
          fontSize: 22, // Taille augmentée
        ),
        decoration: InputDecoration(
          hintText: hintText ?? 'Que veux-tu dire ?',
          hintStyle: const TextStyle(
            fontFamily: 'AvenirNext',
            fontWeight: FontWeight.w100,
            fontSize: 26,
            color: Color(0xFFacacad),
          ),
          border: InputBorder.none,
          //contentPadding: const EdgeInsets.all(16.0),
          counterText: '', // Cache le compteur de caractères
        ),
      ),
    );
  }
}
