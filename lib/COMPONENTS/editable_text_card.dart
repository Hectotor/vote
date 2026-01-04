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
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: isPublished
          ? Builder(
              builder: (context) {
                final words = initialText.split(' ');
                return Wrap(
                  alignment: textAlign == TextAlign.center 
                      ? WrapAlignment.center
                      : textAlign == TextAlign.end
                          ? WrapAlignment.end
                          : WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: words.asMap().entries.map((entry) {
                    final index = entry.key;
                    final word = entry.value;
                    return FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.center,
                      child: Text(
                        word + (index < words.length - 1 ? ' ' : ''),
                        style: style,
                        softWrap: false,
                      ),
                    );
                  }).toList(),
                );
              },
            )
          : TextField(
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
            ),
    );
  }
}
