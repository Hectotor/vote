import 'package:flutter/material.dart';
import 'package:toplyke/COMPONENTS/image_vote_card.dart';

class PollGridDisplay extends StatefulWidget {
  final List<dynamic> blocs;
  final String type;

  const PollGridDisplay({
    Key? key,
    required this.blocs,
    required this.type,
  }) : super(key: key);

  @override
  State<PollGridDisplay> createState() => _PollGridDisplayState();
}

class _PollGridDisplayState extends State<PollGridDisplay> {
  int? _tappedIndex;
  
  void _handleTap(int index) {
    setState(() {
      _tappedIndex = index;
    });
    // Réinitialiser après l'animation
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _tappedIndex = null;
        });
      }
    });
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
                  onTap: () => _handleTap(0),
                  child: ImageVoteCard(
                    bloc: widget.blocs[0],
                    showHeart: _tappedIndex == 0,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => _handleTap(1),
                  child: ImageVoteCard(
                    bloc: widget.blocs[1],
                    showHeart: _tappedIndex == 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Bloc du bas centré
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                child: GestureDetector(
                  onTap: () => _handleTap(2),
                  child: ImageVoteCard(
                    bloc: widget.blocs[2],
                    showHeart: _tappedIndex == 2,
                  ),
                ),
              ),
            ],
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
          onTap: () => _handleTap(index),
          child: ImageVoteCard(
            bloc: widget.blocs[index],
            showHeart: _tappedIndex == index,
          ),
        );
      },
    );
  }
}
