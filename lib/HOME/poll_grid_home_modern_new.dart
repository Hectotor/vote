import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:toplyke/COMPONENTS/vote_percentages.dart';
import 'package:toplyke/COMPONENTS/heart_animation_group.dart';
import 'dart:math';

class PollGridHomeModern extends StatefulWidget {
  final List<String?> images;
  final List<Color> imageFilters;
  final List<String?> textes;
  final String postId;
  final int numberOfBlocs;
  final List<int?> voteCounts;
  final List<List<dynamic>?> votes;
  final List<dynamic>? blocs;

  const PollGridHomeModern({
    super.key,
    required this.images,
    required this.imageFilters,
    required this.textes,
    required this.postId,
    required this.numberOfBlocs,
    required this.voteCounts,
    required this.votes,
    required this.blocs,
  });

  @override
  State<PollGridHomeModern> createState() => _PollGridHomeModernState();
}

class _PollGridHomeModernState extends State<PollGridHomeModern> {
  // Map pour stocker l'état d'animation de chaque bloc
  final Map<int, bool> _showHeartMap = {};
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = widget.numberOfBlocs <= 2 ? widget.numberOfBlocs : 2;
        double spacing = 8;

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: widget.numberOfBlocs,
          padding: const EdgeInsets.all(8.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            return _buildPollCard(context, index);
          },
        );
      },
    );
  }

  Widget _buildPollCard(BuildContext context, int index) {
    final blocKey = ValueKey('${widget.postId}_bloc_$index');
    
    // Initialiser l'état d'animation si nécessaire
    _showHeartMap[index] ??= false;
    
    return GestureDetector(
      onTap: () {
        // Déclencher l'animation du cœur
        setState(() {
          _showHeartMap[index] = true;
          
          // Réinitialiser après l'animation
          Future.delayed(const Duration(milliseconds: 1200), () {
            if (mounted) {
              setState(() {
                _showHeartMap[index] = false;
              });
            }
          });
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              if (widget.images[index] != null)
                Positioned.fill(
                  child: CachedNetworkImage(
                    imageUrl: widget.images[index]!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

              // Filtre couleur
              if (widget.imageFilters[index] != Colors.transparent)
                Container(
                  color: widget.imageFilters[index].withOpacity(0.3),
                ),

              // Overlay dégradé
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black54, Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),

              // Animation des cœurs
              HeartAnimationGroup(
                show: _showHeartMap[index] == true,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
              ),

              // Texte en bas
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    widget.textes[index] ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 4,
                          color: Colors.black45,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Pourcentage
              Positioned(
                top: 10,
                right: 10,
                child: VotePercentages(
                  postId: widget.postId,
                  blocIndex: index,
                  showPercentages: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
