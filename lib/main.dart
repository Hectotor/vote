import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:toplyke/splash_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter/painting.dart';
import 'package:provider/provider.dart';
import 'package:toplyke/COMPONENTS/VOTE/vote_service.dart';
import 'package:toplyke/SERVICES/navigation_service.dart';
import 'dart:async';
import 'package:app_links/app_links.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configuration du cache d'images
  final imageCache = PaintingBinding.instance.imageCache;
  imageCache.maximumSizeBytes = 1024 * 1024 * 200; // 200MB de cache
  
  await Firebase.initializeApp();
  
  // Désactive la rotation de l'écran
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialisation des deep links
  _initDeepLinks();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => VoteService(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

// Gestion des deep links
Future<void> _initDeepLinks() async {
  final appLinks = AppLinks();
  
  // Gérer les liens initiaux (quand l'app est fermée)
  try {
    final initialUri = await appLinks.getInitialAppLink();
    if (initialUri != null) {
      await NavigationService.handleDeepLink(initialUri);
    }
  } catch (e) {
    print('Erreur lors de la récupération du lien initial: $e');
  }

  // Gérer les liens entrants (quand l'app est déjà ouverte)
  appLinks.uriLinkStream.listen((Uri uri) {
    NavigationService.handleDeepLink(uri);
  }, onError: (e) {
    print('Erreur lors de la récupération du lien: $e');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigationService.navigatorKey,
      title: 'Vote',
      theme: ThemeData(
        useMaterial3: true,
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        brightness: Brightness.light,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,  // Empêche l'élévation lors du défilement
          systemOverlayStyle: SystemUiOverlayStyle.light,  // Barre d'état claire
          iconTheme: IconThemeData(color: Color(0xFF212121)),
          titleTextStyle: TextStyle(
            color: Color(0xFF212121),
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        colorScheme: const ColorScheme.light(
          primary: Colors.black,
          secondary: Colors.black,
          surface: Colors.white,
          background: Colors.white,
          error: Colors.red,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.black87,
          onBackground: Colors.black87,
          onError: Colors.white,
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 4,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF212121)),
          bodyMedium: TextStyle(color: Color(0xFF212121)),
          titleLarge: TextStyle(color: Color(0xFF212121)),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF212121),
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [
        Locale('fr', 'FR'), // Add French locale
        Locale('en', ''),
      ],
      home: const SplashScreen(), // Set ScreenPage as the home widget
    );
  }
}

class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: child,
    );
  }
}
