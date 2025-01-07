import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
//import 'package:vote_app/INSCRIPTION/connexion.dart';
import 'package:vote_app/navBar.dart'; // Import localization package
//import 'package:vote_app/INSCRIPTION/inscription.dart';

//import 'navBar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Firebase Demo',
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Colors.white,
          secondary: Colors.white,
          surface: Colors.white,
          background: Colors.white,
          error: Colors.black,
          onPrimary: Colors.black,
          onSecondary: Colors.black,
          onSurface: Colors.black,
          onBackground: Colors.black,
          onError: Colors.black,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.transparent, // Set to transparent
        //fontFamily: 'AvenirNext',
        //textTheme: const TextTheme(
        //bodyLarge: TextStyle(fontFamily: 'AvenirNext'),
        //bodyMedium: TextStyle(fontFamily: 'AvenirNext'),
        //titleLarge: TextStyle(fontFamily: 'AvenirNext'),
        //titleMedium: TextStyle(fontFamily: 'AvenirNext'),
        //titleSmall: TextStyle(fontFamily: 'AvenirNext'),
        //),
      ),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [
        Locale('fr', 'FR'), // Add French locale
      ],
      home: const GradientBackground(child: NavBar()), // Use GradientBackground
    );
  }
}

class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1D1D2C), // Dégradé sombre
            Color(0xFF1D1D2C),
            //Color(0xFF24243E),
          ],
        ),
      ),
      child: child,
    );
  }
}
