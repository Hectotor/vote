import 'package:flutter/material.dart';
import 'package:toplyke/COMPONENTS/image_vote_card.dart';
import 'package:toplyke/SERVICES/vote_service.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PollGridDisplay extends StatefulWidget {
  final List<dynamic> blocs;
  final String type;
  final String postId;

  const PollGridDisplay({
    Key? key,
    required this.blocs,
    required this.type,
    required this.postId,
  }) : super(key: key);

  @override
  State<PollGridDisplay> createState() => _PollGridDisplayState();
}

class _PollGridDisplayState extends State<PollGridDisplay> {
  int _tappedIndex = -1;
  bool _hasVoted = false;
  late final VoteService _voteService;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _voteService = Provider.of<VoteService>(context, listen: false);
    _checkVoteStatus();
  }

  // Vérifier si l'utilisateur a déjà voté
  Future<void> _checkVoteStatus() async {
    try {
      final hasVoted = await _voteService.hasUserVoted(widget.postId);
      if (mounted) {
        setState(() {
          _hasVoted = hasVoted;
        });
      }
    } catch (e) {
      print('Erreur lors de la vérification du statut de vote: $e');
    }
  }

  // Méthode pour voter
  Future<void> _handleVote(int index) async {
    // Vérifier que l'utilisateur est connecté
    final userId = _auth.currentUser?.uid;
    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez vous connecter pour voter')),
      );
      return;
    }
    
    // Vérifier si l'utilisateur a déjà voté
    final hasVoted = await _voteService.hasUserVoted(widget.postId);
    if (hasVoted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vous avez déjà voté pour ce post')),
      );
      return;
    }
    
    // Mettre à jour l'interface immédiatement
    setState(() {
      _tappedIndex = index;
      _hasVoted = true;
    });
    
    // Enregistrer le vote en arrière-plan
    await _voteService.vote(widget.postId, index.toString(), userId);
    
    // Réinitialiser l'animation après un délai
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _tappedIndex = -1;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    try {
      // Vérifier que les blocs sont valides
      if (widget.blocs.isEmpty) {
        return const Center(
          child: Text(
            'Aucun bloc à afficher',
            style: TextStyle(color: Colors.white),
          ),
        );
      }
      
      // Utiliser StreamBuilder pour les mises à jour en temps réel
      return StreamBuilder<Map<String, int>>(
        stream: _voteService.watchVotes(widget.postId),
        builder: (context, snapshot) {
          // Utiliser les données du stream ou une Map vide par défaut
          final votes = snapshot.data ?? {};
          
          // Calcul sécurisé du pourcentage
          double calculatePercentage(String blocId) {
            try {
              final totalVotes = votes.values.fold<int>(0, (a, b) => a + b);
              if (totalVotes == 0) return 0;
              return (votes[blocId] ?? 0) / totalVotes * 100;
            } catch (e) {
              print('Erreur de calcul de pourcentage: $e');
              return 0;
            }
          }
          
          // Créer une ImageVoteCard de manière sécurisée
          Widget createVoteCard(int index) {
            try {
              final bloc = widget.blocs[index];
              final blocId = index.toString();
              
              return GestureDetector(
                onTap: _hasVoted ? null : () => _handleVote(index),
                child: ImageVoteCard(
                  bloc: bloc,
                  showHeart: _tappedIndex == index,
                  showPercentage: _hasVoted,
                  percentage: _hasVoted ? calculatePercentage(blocId) : null,
                ),
              );
            } catch (e) {
              print('Erreur lors de la création de la carte de vote: $e');
              return Container(
                color: Colors.grey[800],
                child: const Center(child: Icon(Icons.error, color: Colors.white)),
              );
            }
          }
          
          // Affichage spécifique pour le type 'triple'
          if (widget.type == 'triple' && widget.blocs.length >= 3) {
            return Column(
              children: [
                // Ligne du haut avec 2 blocs
                Row(
                  children: [
                    Expanded(child: createVoteCard(0)),
                    const SizedBox(width: 8),
                    Expanded(child: createVoteCard(1)),
                  ],
                ),
                // Bloc du bas centré
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2,
                        child: createVoteCard(2),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          
          // Layout par défaut pour les autres types
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: widget.blocs.length <= 2 ? 2 : 
                             widget.blocs.length == 3 ? 2 : 
                             widget.blocs.length == 4 ? 2 : 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.0,
            ),
            itemCount: widget.blocs.length,
            itemBuilder: (context, index) => createVoteCard(index),
          );
        },
      );
    } catch (e) {
      print('Erreur globale dans PollGridDisplay: $e');
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
