import 'package:flutter/material.dart';
import '../../SERVICES/auth_redirect_service.dart';

class CommentInput extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  
  /// Méthode statique pour envoyer un commentaire avec vérification d'authentification
  static Future<bool> sendWithAuthCheck(BuildContext context, VoidCallback onSend) async {
    return await AuthRedirectService.executeIfAuthenticated(
      context,
      () async {
        onSend();
        return true;
      }
    ) ?? false;
  }

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
    _isTextEmpty = widget.controller.text.trim().isEmpty;
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

    // Forcer la première lettre en majuscule
    final text = widget.controller.text;
    if (text.isNotEmpty) {
      // Mettre en majuscule après les points
      final capitalized = text.split('.').map((sentence) {
        if (sentence.isEmpty) return sentence;
        return sentence[0].toUpperCase() + sentence.substring(1);
      }).join('.');
      
      if (capitalized != text) {
        widget.controller.value = TextEditingValue(
          text: capitalized,
          selection: TextSelection.collapsed(offset: capitalized.length),
        );
      }
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
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 8, top: 8, bottom: 8),
                child: TextField(
                  controller: widget.controller,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Ajouter un commentaire...',
                    hintStyle: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  maxLines: 5,
                  minLines: 1,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  onChanged: (text) {
                    setState(() {
                      _isTextEmpty = text.trim().isEmpty;
                      if (text.contains('\n')) {
                        widget.controller.text = text.replaceAll('\n', ' ');
                        widget.controller.selection = TextSelection.fromPosition(
                          TextPosition(offset: widget.controller.text.length),
                        );
                      }
                    });
                  },
                  onSubmitted: (text) async {
                    if (!_isTextEmpty) {
                      // Vu00e9rifier l'authentification avant d'envoyer le commentaire
                      await CommentInput.sendWithAuthCheck(context, widget.onSend);
                    }
                  },
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send, 
                color: _isTextEmpty ? Colors.grey : Colors.blue,
              ),
              onPressed: _isTextEmpty
                  ? null
                  : () async {
                      print('Bouton envoyer appuyé');
                      // Vérifier l'authentification avant d'envoyer le commentaire
                      await CommentInput.sendWithAuthCheck(context, widget.onSend);
                    },
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}
