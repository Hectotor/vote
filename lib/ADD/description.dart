import 'package:flutter/material.dart';
//import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firebase Firestore

class Description extends StatelessWidget {
  final TextEditingController controller;

  const Description({
    super.key,
    required this.controller,
  });

  void _logHashtags() {
    final text = controller.text;
    final hashtags =
        text.split(' ').where((word) => word.startsWith('#')).toList();
    for (var hashtag in hashtags) {
      print('Hashtag found: $hashtag'); // Log each hashtag
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
      width: 350, // Largeur fixe pour harmoniser le design
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: TextFormField(
        controller: controller,
        minLines: 1,
        maxLines: 5, // Permet plusieurs lignes pour la description
        maxLength: 200, // Limite le texte à 150 caractères
        textAlign: TextAlign.start,
        style: const TextStyle(
          fontFamily: 'AvenirNext',
          fontWeight: FontWeight.w500,
          fontSize: 18,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          hintText: 'Ajoute un commentaire ou des hashtags...',
          hintStyle: const TextStyle(
            fontFamily: 'AvenirNext',
            fontWeight: FontWeight.w100,
            fontSize: 18,
            color: Color(0xFFacacad),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(8.0),
          counterText: '', // Cache le compteur de caractères
        ),
        onChanged: (text) {
          _logHashtags(); // Log hashtags whenever the text changes
        },
      ),
    );
  }
}
