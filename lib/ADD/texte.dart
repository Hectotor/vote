import 'package:flutter/material.dart';

class TexteWidget extends StatefulWidget {
  final TextEditingController controller;
  final bool isVisible;
  final Function(bool) onVisibilityChanged;

  const TexteWidget({
    Key? key,
    required this.controller,
    required this.isVisible,
    required this.onVisibilityChanged,
  }) : super(key: key);

  @override
  _TexteWidgetState createState() => _TexteWidgetState();
}

class _TexteWidgetState extends State<TexteWidget> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(15),
        bottomRight: Radius.circular(15),
      ),
      child: widget.isVisible ? Container(
        decoration: widget.controller.text.isNotEmpty 
          ? BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.0),
                  Colors.black.withOpacity(0.8), 
                ],
              ),
            )
          : null,
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: widget.controller,
          autofocus: false,
          textAlign: TextAlign.center,
          textCapitalization: TextCapitalization.sentences,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          cursorColor: Colors.white,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          textInputAction: TextInputAction.done,
          onChanged: (value) {
            setState(() {
              // Trigger rebuild when text changes
            });
          },
          onSubmitted: (value) {
            widget.onVisibilityChanged(true);
          },
        ),
      ) : TextField(
        controller: widget.controller,
        autofocus: false,
        textAlign: TextAlign.center,
        textCapitalization: TextCapitalization.sentences,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        cursorColor: Colors.white,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        textInputAction: TextInputAction.done,
        onSubmitted: (value) {
          widget.onVisibilityChanged(true);
        },
      ),
    );
  }
}
