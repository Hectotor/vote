import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../navBar.dart';

class EmailConfirmationPopup extends StatefulWidget {
  final String email;

  const EmailConfirmationPopup({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  State<EmailConfirmationPopup> createState() => _EmailConfirmationPopupState();
}

class _EmailConfirmationPopupState extends State<EmailConfirmationPopup> {
  bool _showOptions = false;
  final PageController _pageController = PageController();
  bool _isEmailVerified = false;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _startEmailVerificationCheck();
  }

  @override
  void dispose() {
    _emailVerificationSubscription?.cancel();
    super.dispose();
  }

  StreamSubscription? _emailVerificationSubscription;

  void _startEmailVerificationCheck() {
    _emailVerificationSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        setState(() {
          _isEmailVerified = user.emailVerified;
        });
        if (_isEmailVerified) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const NavBar()),
            (route) => false,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Icon(Icons.email, color: Colors.blue, size: 48),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Vérification de l\'email',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Clique sur le lien pour activer ton compte et rejoindre la communauté TopLyke 🔥',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              letterSpacing: 0.5,
            ),
          ),
          if (_isChecking)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Vérification en cours...',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      actions: [
        Center(
          child: TextButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null && user.emailVerified) {
                // Si l'email est vérifié, rediriger vers la navigation
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const NavBar()),
                  (route) => false,
                );
              } else {
                // Sinon, afficher les options en dessous du bouton
                setState(() {
                  _showOptions = true;
                });
              }
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
                  'Vérifier',
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
        if (_showOptions)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Column(
              children: [
                TextButton(
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) return;
                    
                    try {
                      await user.sendEmailVerification();
                      setState(() {
                        _showOptions = false;
                      });
                      Navigator.pop(context);
                    } catch (e) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Erreur'),
                          content: Text('Erreur: ${e.toString()}'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Renvoyer l\'email',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.popUntil(context, ModalRoute.withName('/inscription'));
                    // Rediriger vers l'étape 4 (email)
                    _pageController.jumpToPage(3);
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Modifier l\'adresse mail',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
