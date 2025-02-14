import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vote_app/INSCRIPTION/connexion.dart';
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
        useMaterial3: true,
        brightness: Brightness.dark,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A1A),
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFFE0E0E0)),
          titleTextStyle: TextStyle(
            color: Color(0xFFE0E0E0),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFFFFF),      // Bleu principal
          secondary: Color(0xFF64B5F6),    // Bleu secondaire
          surface: Color(0xFF1A1A1A),      // Surface des cartes
          background: Color(0xFF121212),   // Arrière-plan principal
          error: Color(0xFFCF6679),        // Couleur d'erreur
          onPrimary: Color(0xFFFFFFFF),    // Texte sur primary
          onSecondary: Color(0xFF000000),  // Texte sur secondary
          onSurface: Color(0xFFE0E0E0),    // Texte sur surface
          onBackground: Color(0xFFE0E0E0), // Texte sur background
          onError: Color(0xFF000000),      // Texte sur error
        ),
        cardTheme: const CardTheme(
          color: Color(0xFF1A1A1A),
          elevation: 4,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFFE0E0E0)),
          bodyMedium: TextStyle(color: Color(0xFFE0E0E0)),
          titleLarge: TextStyle(color: Color(0xFFE0E0E0)),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFFE0E0E0),
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [
        Locale('fr', 'FR'), // Add French locale
      ],
      home: const GradientBackground(
          child: ConnexionPage()), // Use GradientBackground
    );
  }
}

class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
      ),
      child: SafeArea(
        child: child,
      ),
    );
  }
}
