import 'package:flutter/material.dart';

class BioField extends StatefulWidget {
  final Map<String, dynamic> userData;
  final TextEditingController controller;

  const BioField({
    Key? key,
    required this.userData,
    required this.controller,
  }) : super(key: key);

  @override
  State<BioField> createState() => _BioFieldState();
}

class _BioFieldState extends State<BioField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.controller,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: 'Ajoute une bio...',
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
          cursorColor: Colors.white,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
        ),
      ],
    );
  }
}
