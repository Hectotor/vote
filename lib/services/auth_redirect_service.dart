import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../INSCRIPTION/connexion_screen.dart';

/// Service pour gérer les redirections liées à l'authentification
class AuthRedirectService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Vérifie si l'utilisateur est connecté et le redirige vers la page de connexion si nécessaire
  /// 
  /// Retourne true si l'utilisateur est connecté et son email est vérifié, false s'il a été redirigé
  static bool checkAuthAndRedirect(BuildContext context) {
    if (_auth.currentUser == null) {
      _redirectToLogin(context);
      return false;
    }
    
    // Vérifier si l'email est vérifié
    if (!_auth.currentUser!.emailVerified) {
      _redirectToLogin(context);
      return false;
    }
    
    return true;
  }

  /// Exécute une fonction si l'utilisateur est connecté et son email est vérifié,
  /// sinon le redirige vers la page de connexion
  /// 
  /// Retourne le résultat de la fonction si l'utilisateur est authentifié, null sinon
  static Future<T?> executeIfAuthenticated<T>(
    BuildContext context, 
    Future<T> Function() action
  ) async {
    if (_auth.currentUser == null) {
      _redirectToLogin(context);
      return null;
    }
    
    // Vérifier si l'email est vérifié
    if (!_auth.currentUser!.emailVerified) {
      _redirectToLogin(context);
      return null;
    }

    try {
      return await action();
    } catch (e) {
      // Afficher un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}'))
      );
      return null;
    }
  }

  /// Redirige l'utilisateur vers la page de connexion
  static void redirectToLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ConnexionPage(),
      ),
    );
  }

  /// Redirige l'utilisateur vers la page de connexion (méthode privée)
  static void _redirectToLogin(BuildContext context) {
    redirectToLogin(context);
  }

  /// Vérifie si l'utilisateur est connecté
  static bool isAuthenticated() {
    return _auth.currentUser != null;
  }
  
  /// Vérifie si l'utilisateur est connecté et son email est vérifié
  static bool isFullyAuthenticated() {
    return _auth.currentUser != null && _auth.currentUser!.emailVerified;
  }

  /// Récupère l'ID de l'utilisateur actuel
  static String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }
}
