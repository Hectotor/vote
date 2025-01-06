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
      print('Hashtag found: $hashtag'); // Log each hashtag
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      minLines: 1,
      maxLines: 1, // Limit to a single line
      maxLength: 200, // Limit the text to 200 characters
      textAlign: TextAlign.start,
      style: const TextStyle(
        fontFamily: 'AvenirNext',
        fontWeight: FontWeight.w500,
        fontSize: 18,
        color: Colors.white, // Text in white for good contrast
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.transparent, // Transparent background
        hintText: 'Ajoute un commentaire ou des hashtags...',
        hintStyle: const TextStyle(
          fontFamily: 'AvenirNext',
          fontWeight: FontWeight.w100,
          fontSize: 18,
          color: Colors.grey, // Hint text in grey
        ),
        border: InputBorder.none, // Remove border
        counterText: '', // Hide character counter
      ),
      onChanged: (text) {
        _logHashtags(); // Log hashtags whenever the text changes
      },
      onFieldSubmitted: (text) {
        // Prevent new lines by doing nothing on Enter
      },
    );
  }
}
