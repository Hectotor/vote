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
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8, top: 4),
      child: RichText(
        text: TextSpan(
          children: [
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
