import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      // Si l'utilisateur n'est pas authentifié, afficher un message
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Connecte toi pour commenter',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(

        border: Border(
          top: BorderSide(
            color: Colors.grey[850]!,
            width: 0.1,
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
                    fontSize: 15,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Ajouter un commentaire...',
                    hintStyle: TextStyle(
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
                color: _isTextEmpty ? Color(0xFF212121) : Colors.blue,
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
