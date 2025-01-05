import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'navBar.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        fontFamily: 'AvenirNext', // Ajout de la police par défaut
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontFamily: 'AvenirNext'),
          bodyMedium: TextStyle(fontFamily: 'AvenirNext'),
          titleLarge: TextStyle(fontFamily: 'AvenirNext'),
          titleMedium: TextStyle(fontFamily: 'AvenirNext'),
          titleSmall: TextStyle(fontFamily: 'AvenirNext'),
        ),
      ),
      home: const NavBar(),
    );
  }
}
