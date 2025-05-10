import 'package:flutter/material.dart';

class CommentExpander extends StatefulWidget {
  final String text;
  final double maxLines;
  final VoidCallback? onExpand;

  const CommentExpander({
    Key? key,
    required this.text,
    this.maxLines = 2,
    this.onExpand,
  }) : super(key: key);

  @override
  State<CommentExpander> createState() => _CommentExpanderState();
}

class _CommentExpanderState extends State<CommentExpander> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final span = TextSpan(
          text: widget.text,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        );
        final tp = TextPainter(
          text: span,
          maxLines: widget.maxLines.toInt(),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        final isOverflow = tp.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: _isExpanded ? double.infinity : widget.maxLines * 20,
              ),
              child: SingleChildScrollView(
                child: Text(
                  widget.text,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
            if (isOverflow)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                    if (widget.onExpand != null) {
                      widget.onExpand!();
                    }
                  },
                  child: Text(
                    _isExpanded ? 'Afficher moins' : 'Afficher plus',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
