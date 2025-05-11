import 'package:flutter/material.dart';
import 'package:toplyke/COMPONENTS/poll_grid_display.dart';

class PollGridHomeModern extends StatelessWidget {
  final List<Map<String, dynamic>>? blocs;
  final String postId;

  const PollGridHomeModern({
    Key? key,
    required this.blocs,
    required this.postId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // S'assurer que les blocs sont correctement formatés
    final safeBlocs = blocs ?? [];
    
    // Déterminer le type en fonction du nombre de blocs
    final type = safeBlocs.length == 2 ? 'duel' : 
               safeBlocs.length == 3 ? 'triple' :
               safeBlocs.length == 4 ? 'quad' : 'custom';
    
    // Envelopper dans un try-catch pour éviter les plantages
    try {
      return PollGridDisplay(
        blocs: safeBlocs,
        type: type,
        postId: postId, 
      );
    } catch (e) {
      print('Erreur dans PollGridHomeModern: $e');
      // Retourner un widget de secours en cas d'erreur
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Center(
          child: Text(
            'Impossible d\'afficher ce sondage',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }
}
