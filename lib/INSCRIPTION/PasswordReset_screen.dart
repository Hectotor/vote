import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Si vous utilisez Firestore pour envoyer le code
import 'package:firebase_auth/firebase_auth.dart'; // Si vous utilisez Firebase Authentication

class PasswordResetPage extends StatefulWidget {
  @override
  _PasswordResetPageState createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final TextEditingController emailController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;
  FocusNode? emailFocusNode;

  void _sendCode(BuildContext context) async {
    String email = emailController.text.trim();
    if (!_isValidEmail(email)) {
      setState(() {
        _errorMessage = 'Veuillez entrer une adresse e-mail valide.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Logique pour envoyer le code à l'e-mail
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      // Afficher un message de confirmation
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Code envoyé à $email')));
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de l’envoi du code. Veuillez réessayer.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _isValidEmail(String email) {
    // Simple regex for email validation
    final RegExp emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegExp.hasMatch(email);
  }

  @override
  void initState() {
    super.initState();
    emailFocusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(emailFocusNode);
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    emailFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mot de passe oublié')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: TextField(
                controller: emailController,
                focusNode: emailFocusNode,
                decoration: InputDecoration(
                  labelText: 'Entrez votre adresse e-mail',
                  errorText: _errorMessage,
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[400] ?? Colors.grey), // Fix the color assignment error
                  ),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              onPressed: _isLoading ? null : () => _sendCode(context),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue[600]!, 
                      Colors.blue[900]!
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                curve: Curves.easeInOut,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  alignment: Alignment.center,
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Envoyer le code',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 24,
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}