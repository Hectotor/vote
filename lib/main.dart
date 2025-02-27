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
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        brightness: Brightness.dark,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF151019),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          secondary: Colors.white,
          surface: Color(0xFF151019),
          background: Color(0xFF151019),
          error: Colors.white,
          onPrimary: Color(0xFF151019),
          onSecondary: Color(0xFF151019),
          onSurface: Colors.white,
          onBackground: Colors.white,
          onError: Color(0xFF151019),
        ),
        cardTheme: const CardTheme(
          color: Color(0xFF151019),
          elevation: 4,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        scaffoldBackgroundColor: Color(0xFF151019),
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
      child: child,
    );
  }
}
