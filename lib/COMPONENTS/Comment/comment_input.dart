import 'package:flutter/material.dart';

class CommentInput extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const CommentInput({
    Key? key,
    required this.controller,
    required this.onSend,
  }) : super(key: key);

  @override
  State<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  bool _isTextEmpty = true;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateTextState);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateTextState);
    super.dispose();
  }

  void _updateTextState() {
    final newIsEmpty = widget.controller.text.trim().isEmpty;
    if (_isTextEmpty != newIsEmpty) {
      setState(() {
        _isTextEmpty = newIsEmpty;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        border: Border(
          top: BorderSide(
            color: Colors.grey[850]!,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border(
                  top: BorderSide(
                    color: Colors.grey[850]!,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Ajouter un commentaire...',
                        hintStyle: const TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (text) {
                        setState(() {
                          _isTextEmpty = text.trim().isEmpty;
                        });
                      },
                      onSubmitted: (text) {
                        if (!_isTextEmpty) {
                          widget.onSend();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _isTextEmpty
                        ? null
                        : () {
                            print('Bouton envoyer appuyé');
                            widget.onSend();
                          },
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
