import 'package:flutter/material.dart';

class PostDescription extends StatelessWidget {
  final String pseudo;
  final String description;
  final bool isDarkMode;

  const PostDescription({
    Key? key,
    required this.pseudo,
    required this.description,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$pseudo ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            TextSpan(
              text: description,
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
