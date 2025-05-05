import 'package:flutter/material.dart';
import 'package:toplyke/INSCRIPTION/connexion_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toplyke/navBar.dart';

/// SplashScreen widget that displays a splash screen with animation
class SplashScreen extends StatefulWidget {
  /// Constructor for SplashScreen
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  /// Duration for splash screen animation
  //final int _splashScreenDuration = 3;

  /// Duration for animation
  final int _animationDuration = 2;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Attendre que Firebase soit initialisé
      await Future.delayed(const Duration(seconds: 2));

      // Vérifier si l'utilisateur est connecté
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Vérifier si l'email est vérifié
        if (!user.emailVerified) {
          // Rediriger vers la page de connexion
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ConnexionPage()),
          );
          return;
        }

        // Rediriger vers la page principale
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NavBar()),
        );
      } else {
        // Rediriger vers la page de connexion si l'utilisateur n'est pas connecté
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ConnexionPage()),
        );
      }
    } catch (e) {
      print('Erreur lors de l\'initialisation : $e');
      // En cas d\'erreur, rediriger vers la page de connexion
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ConnexionPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// Animation builder for splash screen
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: Duration(seconds: _animationDuration),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value * 0.70,
                  child: Opacity(
                    opacity: 1.0,
                    child: Column(
                      children: [
                        Image.asset('assets/logo/icon.png'),
                        const SizedBox(height: 20),
                        const Text(
                          'TopLyke',
                          style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            fontFamily: 'AvenirNext',
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
