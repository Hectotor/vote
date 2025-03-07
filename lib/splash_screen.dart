import 'package:flutter/material.dart';
import 'package:toplyke/INSCRIPTION/connexion_screen.dart';

/// SplashScreen widget that displays a splash screen with animation
class SplashScreen extends StatefulWidget {
  /// Constructor for SplashScreen
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  /// Duration for splash screen animation
  final int _splashScreenDuration = 3;

  /// Duration for animation
  final int _animationDuration = 2;

  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  /// Function to navigate to the login page after a delay
  void _navigateToLogin() async {
    try {
      /// Delay for splash screen
      await Future.delayed(Duration(seconds: _splashScreenDuration));
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => ConnexionPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;

            var tween = Tween(begin: begin, end: end);
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        ),
      );
    } catch (e) {
      /// Handle navigation error
      print('Error navigating to login: $e');
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
