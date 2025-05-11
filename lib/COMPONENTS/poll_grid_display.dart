import 'dart:async';

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
  Map<String, int> _votes = {};
  late final VoteService _voteService;
  final _auth = FirebaseAuth.instance;
  late StreamSubscription<bool> _voteSubscription;

  @override
  void initState() {
    super.initState();
    _voteService = Provider.of<VoteService>(context, listen: false);
    _loadVotes();
    
    // Écouter les changements d'état de vote
    _voteSubscription = _voteService.hasUserVoted(widget.postId).listen((hasVoted) {
      if (mounted) {
        setState(() {
          _hasVoted = hasVoted;
        });
      }
    });
  }

  @override
  void dispose() {
    _voteSubscription.cancel();
    super.dispose();
  }

  Future<void> _loadVotes() async {
    for (var i = 0; i < widget.blocs.length; i++) {
      final bloc = widget.blocs[i];
      final blocId = bloc['id'] ?? i.toString(); // Utiliser l'index comme ID si non défini
      
      try {
        final votes = await _voteService
            .getVoteCount(widget.postId, blocId)
            .first;
            
        if (mounted) {
          setState(() {
            _votes[blocId] = votes;
          });
        }
      } catch (e) {
        debugPrint('Erreur lors du chargement des votes pour le bloc $i: $e');
        // Initialiser à 0 en cas d'erreur
        if (mounted) {
          setState(() {
            _votes[blocId] = 0;
          });
        }
      }
    }
  }

  Future<void> _handleVote(int index) async {
    if (_hasVoted) return;

    try {
      final bloc = widget.blocs[index];
      final blocId = bloc['id'] ?? index.toString();
      final userId = _auth.currentUser?.uid ?? ''; // Récupère l'ID de l'utilisateur connecté
      
      if (userId.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Veuillez vous connecter pour voter')),
          );
        }
        return;
      }
      
      await _voteService.vote(widget.postId, blocId, userId);
      
      if (mounted) {
        setState(() {
          _tappedIndex = index;
          _hasVoted = true;
          _votes[blocId] = (_votes[blocId] ?? 0) + 1;
        });

        // Réinitialiser l'animation après un délai
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            setState(() {
              _tappedIndex = -1;
            });
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.type == 'triple' && widget.blocs.length >= 3) {
      return Column(
        children: [
          // Ligne du haut avec 2 blocs
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _hasVoted ? null : () => _handleVote(0),
                  child: ImageVoteCard(
                    bloc: widget.blocs[0],
                    showHeart: _tappedIndex == 0,
                    showPercentage: _hasVoted,
                    percentage: _hasVoted && _votes[widget.blocs[0]['id'] ?? '0'] != null
                        ? (_votes[widget.blocs[0]['id'] ?? '0']! / _votes.values.fold(0, (a, b) => a + b)) * 100
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: _hasVoted ? null : () => _handleVote(1),
                  child: ImageVoteCard(
                    bloc: widget.blocs[1],
                    showHeart: _tappedIndex == 1,
                    showPercentage: _hasVoted,
                    percentage: _hasVoted && _votes[widget.blocs[1]['id'] ?? '1'] != null
                        ? (_votes[widget.blocs[1]['id'] ?? '1']! / _votes.values.fold(0, (a, b) => a + b)) * 100
                        : null,
                  ),
                ),
              ),
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
                  child: GestureDetector(
                    onTap: _hasVoted ? null : () => _handleVote(2),
                    child: ImageVoteCard(
                      bloc: widget.blocs[2],
                      showHeart: _tappedIndex == 2,
                      showPercentage: _hasVoted,
                      percentage: _hasVoted && _votes[widget.blocs[2]['id'] ?? '2'] != null
                          ? (_votes[widget.blocs[2]['id'] ?? '2']! / _votes.values.fold(0, (a, b) => a + b)) * 100
                          : null,
                    ),
                  ),
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
      itemBuilder: (context, index) {
        final bloc = widget.blocs[index];
        final blocId = bloc['id'] ?? index.toString();
        
        return GestureDetector(
          onTap: _hasVoted ? null : () => _handleVote(index),
          child: ImageVoteCard(
            bloc: bloc,
            showHeart: _tappedIndex == index,
            showPercentage: _hasVoted,
            percentage: _hasVoted && _votes[blocId] != null
                ? (_votes[blocId]! / _votes.values.fold(0, (a, b) => a + b)) * 100
                : null,
          ),
        );
      },
    );
  }
}
