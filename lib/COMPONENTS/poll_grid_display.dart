import 'package:flutter/material.dart';
import 'package:toplyke/COMPONENTS/image_vote_card.dart';
import 'package:toplyke/SERVICES/vote_service.dart';
import 'package:provider/provider.dart';

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
  int? _tappedIndex;
  bool _hasVoted = false;
  Map<String, int> _votes = {};
  late final VoteService _voteService;

  @override
  void initState() {
    super.initState();
    _voteService = context.read<VoteService>();
    _checkVoteStatus();
    _loadVotes();
  }

  Future<void> _checkVoteStatus() async {
    final hasVoted = await _voteService.hasUserVoted(widget.postId);
    if (mounted) {
      setState(() {
        _hasVoted = hasVoted;
      });
    }
  }

  Future<void> _loadVotes() async {
    for (var bloc in widget.blocs) {
      final votes = await _voteService
          .getVoteCount(widget.postId, bloc['id'])
          .first;
      if (mounted) {
        setState(() {
          _votes[bloc['id']] = votes;
        });
      }
    }
  }

  Future<void> _handleVote(int index) async {
    if (_hasVoted) return;

    try {
      final blocId = widget.blocs[index]['id'];
      await _voteService.vote(widget.postId, blocId);
      
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
              _tappedIndex = null;
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
                    percentage: _hasVoted && _votes[widget.blocs[0]['id']] != null
                        ? (_votes[widget.blocs[0]['id']]! / _votes.values.fold(0, (a, b) => a + b)) * 100
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
                    percentage: _hasVoted && _votes[widget.blocs[1]['id']] != null
                        ? (_votes[widget.blocs[1]['id']]! / _votes.values.fold(0, (a, b) => a + b)) * 100
                        : null,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Ligne du bas avec 1 bloc
          GestureDetector(
            onTap: _hasVoted ? null : () => _handleVote(2),
            child: ImageVoteCard(
              bloc: widget.blocs[2],
              showHeart: _tappedIndex == 2,
              showPercentage: _hasVoted,
              percentage: _hasVoted && _votes[widget.blocs[2]['id']] != null
                  ? (_votes[widget.blocs[2]['id']]! / _votes.values.fold(0, (a, b) => a + b)) * 100
                  : null,
            ),
          ),
        ],
      );
    }
    
    // Layout par défaut pour les autres types
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: widget.blocs.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: _hasVoted ? null : () => _handleVote(index),
          child: ImageVoteCard(
            bloc: widget.blocs[index],
            showHeart: _tappedIndex == index,
            showPercentage: _hasVoted,
            percentage: _hasVoted && _votes[widget.blocs[index]['id']] != null
                ? (_votes[widget.blocs[index]['id']]! / _votes.values.fold(0, (a, b) => a + b)) * 100
                : null,
          ),
        );
      },
    );
  }
}
