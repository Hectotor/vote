import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PollGridHome extends StatelessWidget {
  final List<String?> images; // Accepte uniquement les URLs d'images
  final List<Color> imageFilters;
  final int numberOfBlocs;
  final List<String?> textes; // Liste des textes pour chaque bloc

  const PollGridHome({
    Key? key,
    required this.images,
    required this.imageFilters,
    required this.numberOfBlocs,
    required this.textes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (numberOfBlocs <= 2) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(4),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: (constraints.maxWidth - 8.0) / (2 * 200.0),
            ),
            itemCount: numberOfBlocs,
            itemBuilder: (context, index) {
              return _buildBloc(context, index);
            },
          );
        } else {
          return Column(
            children: [
              // Première rangée (blocs 1 et 2)
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: _buildBloc(context, 0),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: _buildBloc(context, 1),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 0),
              // Deuxième rangée (blocs 3 et 4)
              if (numberOfBlocs == 3)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: SizedBox(
                            width: (constraints.maxWidth - 8.0) / 2,
                            height: 200.0,
                            child: _buildBloc(context, 2),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              else if (numberOfBlocs == 4)
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: _buildBloc(context, 2),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: _buildBloc(context, 3),
                      ),
                    ),
                  ],
                )
            ],
          );
        }
      },
    );
  }

  Widget _buildBloc(BuildContext context, int index) {
    final screenWidth = MediaQuery.of(context).size.width;
    final blockWidth = (screenWidth - 24.0 - 8.0) / 2;
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.black,
        Colors.black.withOpacity(0.7),
      ],
    );

    return Container(
      width: blockWidth,
      height: 200.0, 
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          images[index] != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: CachedNetworkImage(
                  imageUrl: images[index]!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              )
            : Center(
                child: Icon(
                  Icons.add_photo_alternate_outlined, 
                  size: 40, 
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
          if (imageFilters[index] != Colors.transparent)
            Container(
              decoration: BoxDecoration(
                color: imageFilters[index],
                borderRadius: BorderRadius.circular(15.0),
              ),
            ),
          if (textes[index] != null && textes[index]!.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(15),
                  ),
                ),
                child: Text(
                  textes[index]!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
