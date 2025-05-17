import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../INSCRIPTION/connexion_screen.dart';

class ReusableLoginButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String buttonText;

  const ReusableLoginButton({
    super.key,
    this.onPressed,
    this.buttonText = 'Se connecter',
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onPressed ?? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ConnexionPage()),
                );
              },
              child: Text(buttonText),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
