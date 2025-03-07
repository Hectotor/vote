import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Si vous utilisez Firestore pour envoyer le code
import 'mail_confirm.dart'; // Assurez-vous que le chemin est correct
import 'confirmation_email_screen.dart'; // Import the new screen

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
      // Fetch user data from Firestore
      var userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (userQuery.docs.isEmpty) {
        setState(() {
          _errorMessage = 'Aucun utilisateur trouvé avec cet e-mail.';
        });
        return;
      }

      var userData = userQuery.docs.first.data();
      bool emailVerified = userData['emailVerified'] ?? false;

      if (!emailVerified) {
        setState(() {
          _errorMessage = 'L\'email n\'est pas vérifié.';
        });
        return;
      }

      // Générer un nouveau code de vérification
      String newVerificationCode = EmailConfirmationService.generateVerificationCode();

      // Mettre à jour le code dans Firestore
      await userQuery.docs.first.reference.update({
        'verificationCode': newVerificationCode,
      });

      // Envoyer le nouvel e-mail avec le code de vérification
      await EmailConfirmationService.sendConfirmationEmail(email, newVerificationCode);
      
      // Naviguer vers l'écran de confirmation
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmationEmailPage(
            email: email,
            verificationCode: newVerificationCode,
            isPasswordReset: true,
          ),
        ),
      );
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
                    borderSide: BorderSide(color: Colors.grey[400] ?? Colors.grey), // Fix the color assignment error
                  ),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _sendCode(context),
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
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConfirmationEmailPage(
                      email: emailController.text.trim(),
                      verificationCode: '123456', // Remplacez ceci par le code réel si nécessaire
                      isPasswordReset: true, // Indiquer que l'utilisateur vient de la page de réinitialisation
                    ),
                  ),
                );
              },
              child: Text('Ouvrir Confirmation Email'),
            ),
          ],
        ),
      ),
    );
  }
}