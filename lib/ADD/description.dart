import 'package:flutter/material.dart';

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
      print('Hashtag found: $hashtag');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C54).withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 0.5,
        ),
      ),
      child: TextFormField(
        controller: controller,
        minLines: 1,
        maxLines: 7,
        maxLength: 200,
        textAlign: TextAlign.start,
        style: const TextStyle(
          fontSize: 15,
          color: Colors.white,
        ),
        decoration: InputDecoration(
          hintText: 'Commentaire & Hashtags...',
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.5),
          ),
          border: InputBorder.none,
          counterText: '', // Cacher le compteur en mettant une chaîne vide
        ),
        onChanged: (text) => _logHashtags(),
      ),
    );
  }
}
