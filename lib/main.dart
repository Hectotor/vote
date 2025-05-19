import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:toplyke/splash_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter/painting.dart';
import 'package:provider/provider.dart';
import 'package:toplyke/COMPONENTS/VOTE/vote_service.dart';
import 'package:toplyke/INSCRIPTION/connexion_screen.dart';


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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Toplyke',
      theme: ThemeData(
        useMaterial3: true,
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        brightness: Brightness.light,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF5F5F5),
          elevation: 0,
          scrolledUnderElevation: 0,  // Empêche l'élévation lors du défilement
          systemOverlayStyle: SystemUiOverlayStyle.light,  // Barre d'état claire
          iconTheme: IconThemeData(color: Color(0xFF212121)),
          titleTextStyle: TextStyle(
            color: Color(0xFF212121),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        colorScheme: const ColorScheme.light(
          primary: Colors.black,
          secondary: Colors.black,
          surface: Color(0xFFF5F5F5),
          background: Color(0xFFF5F5F5),
          error: Colors.red,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.black87,
          onBackground: Colors.black87,
          onError: Colors.white,
        ),
        cardTheme: const CardTheme(
          color: Color(0xFFF5F5F5),
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
        scaffoldBackgroundColor: Color(0xFFF5F5F5),
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
