import 'package:flutter/material.dart';

class Hashtags extends StatefulWidget {
  final TextEditingController controller;

  const Hashtags({Key? key, required this.controller}) : super(key: key);

  @override
  _HashtagsState createState() => _HashtagsState();
}

class _HashtagsState extends State<Hashtags> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_formatHashtags);
  }

  void _formatHashtags() {
    String text = widget.controller.text;
    
    // Si le texte est vide, ne rien faire
    if (text.isEmpty) return;

    // Vérifier si le dernier caractère est une lettre
    if (!RegExp(r'[a-zA-Z]').hasMatch(text[text.length - 1])) return;

    // Diviser le texte en mots
    List<String> words = text.split(' ');
    
    // Transformer chaque mot qui ne commence pas par # en hashtag
    List<String> formattedWords = words.map((word) {
      // Ignorer les mots qui sont déjà des hashtags
      if (word.startsWith('#')) return word;
      
      // Convertir le mot en hashtag uniquement s'il contient des lettres
      return RegExp(r'[a-zA-Z]').hasMatch(word) ? '#$word' : word;
    }).toList();

    // Rejoindre les mots
    String formattedText = formattedWords.join(' ');

    // Mettre à jour le contrôleur uniquement si le texte a changé
    if (formattedText != text) {
      widget.controller.value = TextEditingValue(
        text: formattedText,
        selection: TextSelection.collapsed(offset: formattedText.length),
      );
    }
  }

  void _logHashtags() {
    final text = widget.controller.text;
    final hashtags =
        text.split(' ').where((word) => word.startsWith('#')).toList();
    for (var hashtag in hashtags) {
      print('Hashtag: $hashtag');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 120,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: widget.controller,
        decoration: InputDecoration(
          hintText: '✨ Ajoute des hashtags',
          hintStyle: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.tag_rounded,
            color: Colors.grey.shade700,
            size: 22,
          ),
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          counterText: '',
        ),
        style: TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        cursorColor: Colors.grey.shade500,
        maxLines: null,
        maxLength: 200,
        keyboardType: TextInputType.text,
        onChanged: (text) => _logHashtags(),
      ),
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(_formatHashtags);
    super.dispose();
  }
}
