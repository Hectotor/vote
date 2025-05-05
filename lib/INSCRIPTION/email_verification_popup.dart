import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmailVerificationPopup extends StatelessWidget {
  final String email;
  final bool isUnverified;

  const EmailVerificationPopup({
    Key? key,
    required this.email,
    this.isUnverified = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Icon(
        Icons.email_outlined,
        color: isUnverified ? Colors.orange : Colors.blue,
        size: 48,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '📩 Vérification de l\'email',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Un message de confirmation a été envoyé à $email.\n\nClique sur le lien pour activer ton compte et rejoindre la communauté TopLyke 🔥',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              letterSpacing: 0.5,
            ),
          ),
          if (isUnverified) ...[
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  user.sendEmailVerification();
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text('Renvoyer l\'email de vérification'),
            ),
          ],
        ],
      ),
      actions: isUnverified
          ? null
          : [
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
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
                      border: Border.all(color: Colors.blue),
                    ),
                    child: Center(
                      child: Text(
                        'OK',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
    );
  }
}
