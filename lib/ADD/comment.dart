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
    return TextFormField(
      controller: controller,
      minLines: 1,
      maxLines: 2, // Limit to a single line
      maxLength: 45, // Limit to 45 characters
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontFamily: 'AvenirNext',
        fontWeight: FontWeight.w700,
        fontSize: 22,
        color: Colors.white, // Text in white
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.transparent, // Transparent background
        hintText: hintText ?? 'Que veux-tu dire ?',
        hintStyle: TextStyle(
          fontFamily: 'AvenirNext',
          fontWeight: FontWeight.w500,
          fontSize: 25,
          color: Colors.grey[400], // Hint text color
        ),
        counterText: '', // Hide character counter
        contentPadding: const EdgeInsets.symmetric(
          //vertical: 10.0,
          horizontal: 12.0,
        ),
        border: InputBorder.none, // Remove border
      ),
      onFieldSubmitted: (text) {
        // Prevent new lines by doing nothing on Enter
      },
      textInputAction:
          TextInputAction.done, // Change the action button to "Done"
    );
  }
}
