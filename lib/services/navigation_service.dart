import 'package:flutter/material.dart';
import 'package:toplyke/HOME/post_page.dart';

/// Service pour gérer la navigation et les deep links dans l'application
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  /// Méthode pour naviguer vers un post spécifique
  static Future<void> navigateToPost(String postId) async {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => PostPage(postId: postId),
      ),
    );
  }
  
  /// Méthode pour gérer les deep links entrants
  static Future<void> handleDeepLink(Uri uri) async {
    // Gérer les différents types de deep links
    if (uri.path.startsWith('/post/')) {
      final postId = uri.pathSegments.last;
      await navigateToPost(postId);
    }
    // Ajouter d'autres types de deep links si nécessaire
  }
}
