import 'package:flutter/material.dart';

class CommentField extends StatelessWidget {
  final TextEditingController controller;

  const CommentField({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      //textAlign: TextAlign.center,
      textCapitalization: TextCapitalization.sentences,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        //fontWeight: FontWeight.w900,
      ),
      decoration: const InputDecoration(
        hintText: 'Ajoute une description...',
        hintStyle: TextStyle(
          color: Colors.grey,
          fontSize: 16,
          //fontWeight: FontWeight.w400,
        ),
        border: InputBorder.none,
        alignLabelWithHint: true,
      ),
      keyboardType: TextInputType.multiline,
      maxLines: null,
      textInputAction: TextInputAction.newline,
    );
  }
}
