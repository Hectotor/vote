import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PasswordResetPage extends StatefulWidget {
  @override
  _PasswordResetPageState createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final TextEditingController emailController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;
  FocusNode? emailFocusNode;

  void _sendResetEmail(BuildContext context) async {
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
      // Utiliser Firebase pour envoyer l'email de réinitialisation
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      
      // Afficher un popup de succès
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Icon(Icons.check_circle, color: Colors.green, size: 48),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '📩 C\'est envoyé !',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Vérifie ta boîte mail pour réinitialiser ton mot de passe. 📬✨',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            actions: [
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.transparent,
                  ),
                  child: Container(
                    width: 100,
                    height: 40,
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
                    child: Center(
                      child: Text(
                        'OK',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de l\'envoi de l\'email. Veuillez réessayer.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _isValidEmail(String email) {
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [ 
            const SizedBox(height: 10),
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
                    borderSide: BorderSide(color: Colors.grey[400] ?? Colors.grey),
                  ),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
            ),
            // Bouton de test
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Icon(Icons.check_circle, color: Colors.green, size: 48),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '📩 C\'est envoyé !',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Vérifie ta boîte mail pour réinitialiser ton mot de passe. 📬✨',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.pop(context);
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: Colors.transparent,
                            ),
                            child: Container(
                              width: 100,
                              height: 40,
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
                              child: Center(
                                child: Text(
                                  'OK',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text(
                'Voir le popup de succès',
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _sendResetEmail(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
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
                                'Réinitialiser',
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
            ),
          ],
        ),
      ),
    );
  }
}