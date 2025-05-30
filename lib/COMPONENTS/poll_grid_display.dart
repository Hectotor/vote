import 'package:flutter/material.dart';
import 'package:toplyke/COMPONENTS/image_vote_card.dart';
import 'package:toplyke/COMPONENTS/VOTE/vote_service.dart';
import 'package:provider/provider.dart';

class PollGridDisplay extends StatefulWidget {
  final List<dynamic> blocs;
  final String type;
  final String postId;
  final bool forceShowPercentage;
  final String? votedBlocId;

  const PollGridDisplay({
    Key? key,
    required this.blocs,
    required this.type,
    required this.postId,
    this.forceShowPercentage = false,
    this.votedBlocId,
  }) : super(key: key);

  @override
  State<PollGridDisplay> createState() => _PollGridDisplayState();
}

class _PollGridDisplayState extends State<PollGridDisplay> {
  int _tappedIndex = -1;
  bool _hasVoted = false;
  String? _votedBlocId;
  late final VoteService _voteService;

  @override
  void initState() {
    super.initState();
    _voteService = Provider.of<VoteService>(context, listen: false);
    
    // Si forceShowPercentage est true, utiliser directement les valeurs fournies
    if (widget.forceShowPercentage) {
      setState(() {
        _hasVoted = true;
        _votedBlocId = widget.votedBlocId;
      });
    } else {
      // Sinon, vérifier le statut de vote normalement
      _checkVoteStatus();
    }
  }

  // Vérifier si l'utilisateur a déjà voté et récupérer le bloc voté
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

  // Méthode pour voter
  Future<void> _handleVote(int index) async {
    // Mettre à jour l'interface et les données immédiatement (optimiste)
    setState(() {
      _tappedIndex = index;
      _hasVoted = true;
      _votedBlocId = index.toString();
      
      // Mettre à jour le voteCount du bloc local immédiatement
      if (widget.blocs[index] is Map) {
        final bloc = widget.blocs[index] as Map<String, dynamic>;
        bloc['voteCount'] = (bloc['voteCount'] as int? ?? 0) + 1;
      }
    });
    
    // Utiliser la méthode statique qui gère la redirection vers la page de connexion
    final success = await VoteService.voteWithAuthCheck(
      context, 
      widget.postId, 
      index.toString()
    );
    
    // Si le vote a échoué, annuler les changements d'état
    if (!success && mounted) {
      setState(() {
        _hasVoted = false;
        _votedBlocId = null;
        // Rétablir le voteCount précédent
        if (widget.blocs[index] is Map) {
          final bloc = widget.blocs[index] as Map<String, dynamic>;
          bloc['voteCount'] = (bloc['voteCount'] as int? ?? 0) - 1;
        }
      });
    }
    
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
          // Nous n'utilisons plus les données du stream car nous calculons directement à partir des blocs
          
          // Calcul sécurisé du pourcentage
          double calculatePercentage(String blocId) {
            try {
              // Calcul du total des votes directement à partir des blocs
              int totalVotes = 0;
              for (var bloc in widget.blocs) {
                if (bloc is Map && bloc['voteCount'] != null) {
                  totalVotes += (bloc['voteCount'] as int? ?? 0);
                }
              }
              
              // Trouver le bloc correspondant et obtenir son nombre de votes
              int blocVotes = 0;
              for (var i = 0; i < widget.blocs.length; i++) {
                if (i.toString() == blocId && widget.blocs[i] is Map) {
                  blocVotes = (widget.blocs[i]['voteCount'] as int? ?? 0);
                  break;
                }
              }
              
              // Si aucun vote, retourner 0
              if (totalVotes == 0) return 0;
              
              // Calcul du pourcentage exact
              return (blocVotes / totalVotes) * 100;
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
              final isVotedBloc = _votedBlocId == blocId;
              
              return GestureDetector(
                onTap: _hasVoted ? null : () => _handleVote(index),
                child: ImageVoteCard(
                  bloc: bloc,
                  showHeart: _tappedIndex == index,
                  showPercentage: _hasVoted,
                  percentage: _hasVoted ? calculatePercentage(blocId) : null,
                  showHeartOnPercentage: isVotedBloc,
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
            return Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
              child: Column(
              children: [
                // Ligne du haut avec 2 blocs
                Row(
                children: [
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: createVoteCard(0),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: createVoteCard(1),
                    ),
                  ),
                ],
              ),
                // Bloc du bas centré
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2.3, //taille du container bas 3
                        height: MediaQuery.of(context).size.width / 2.3, // Hauteur identique pour maintenir le ratio 1:1
                        child: createVoteCard(2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            );
          }
          
          // Layout par défaut pour les autres types
          return Container(
            // Supprime le padding inférieur pour éviter l'espace après la dernière ligne
            margin: const EdgeInsets.only(bottom: 0),
            child: GridView.builder(
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
                            padding: const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10), // Supprime le padding par défaut
              itemCount: widget.blocs.length,
              itemBuilder: (context, index) => AspectRatio(
                aspectRatio: 1.0,
                child: createVoteCard(index),
              ),
            ),
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
