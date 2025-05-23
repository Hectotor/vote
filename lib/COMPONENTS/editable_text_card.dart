import 'package:flutter/material.dart';

class EditableTextCard extends StatelessWidget {
  final bool isPublished;
  final String initialText;
  final ValueChanged<String> onTextChanged;
  final TextAlign textAlign;
  final TextStyle style;
  final EdgeInsets padding;

  const EditableTextCard({
    Key? key,
    required this.initialText,
    required this.onTextChanged,
    required this.isPublished,
    this.textAlign = TextAlign.center,
    this.style = const TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.w900,
      fontStyle: FontStyle.italic,
    ),
    this.padding = const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: TextField(
        controller: TextEditingController(text: initialText),
        autofocus: false,
        textAlign: textAlign,
        textCapitalization: TextCapitalization.sentences,
        style: style,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        cursorColor: Colors.white,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        textInputAction: TextInputAction.done,
        onChanged: onTextChanged,
        readOnly: isPublished,
      ),
    );
  }
}
