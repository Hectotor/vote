import 'package:flutter/material.dart';
import 'package:toplyke/COMPONENTS/poll_grid_display.dart';
import 'package:toplyke/COMPONENTS/VOTE/vote_service.dart';
import 'package:provider/provider.dart';

class PollGridHomeModern extends StatefulWidget {
  final List<Map<String, dynamic>>? blocs;
  final String postId;

  const PollGridHomeModern({
    Key? key,
    required this.blocs,
    required this.postId,
  }) : super(key: key);

  @override
  State<PollGridHomeModern> createState() => _PollGridHomeModernState();
}

class _PollGridHomeModernState extends State<PollGridHomeModern> {
  bool _hasVoted = false;
  String? _votedBlocId;
  late final VoteService _voteService;

  @override
  void initState() {
    super.initState();
    _voteService = Provider.of<VoteService>(context, listen: false);
    _checkVoteStatus();
  }

  // Vérifier si l'utilisateur a déjà voté pour ce post
  Future<void> _checkVoteStatus() async {
    try {
      final hasVoted = await _voteService.hasUserVoted(widget.postId);
      if (hasVoted) {
        final blocId = await _voteService.getUserVoteBlocId(widget.postId);
        if (mounted) {
          setState(() {
            _hasVoted = hasVoted;
            _votedBlocId = blocId;
          });
        }
      } else if (mounted) {
        setState(() {
          _hasVoted = hasVoted;
          _votedBlocId = null;
        });
      }
    } catch (e) {
      print('Erreur lors de la vérification du statut de vote: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // S'assurer que les blocs sont correctement formatés
    final safeBlocs = widget.blocs ?? [];
    
    // Déterminer le type en fonction du nombre de blocs
    final type = safeBlocs.length == 2 ? 'duel' : 
               safeBlocs.length == 3 ? 'triple' :
               safeBlocs.length == 4 ? 'quad' : 'custom';
    
    // Envelopper dans un try-catch pour éviter les plantages
    try {
      return PollGridDisplay(
        blocs: safeBlocs,
        type: type,
        postId: widget.postId,
        // Passer l'état du vote pour afficher les pourcentages
        forceShowPercentage: _hasVoted,
        votedBlocId: _votedBlocId,
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
