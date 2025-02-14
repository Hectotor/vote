import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class BlocGrid extends StatelessWidget {
  final int numberOfBlocs;
  final VoidCallback onTap;
  final VoidCallback? onDelete; // Callback pour suppression
  final List<XFile?> images; // List to store images
  final ValueChanged<int>? onImageChange; // Callback for image change
  final List<Color> imageFilters; // Ajouter cette ligne
  final List<Widget?> textWidgets; // Nouveau

  const BlocGrid({
    super.key,
    required this.numberOfBlocs,
    required this.onTap,
    this.onDelete,
    required this.images,
    this.onImageChange, // Add this line
    required this.imageFilters, // Ajouter ce paramètre
    required this.textWidgets, // Nouveau
  });

  Widget _buildBloc({
    bool showDeleteButton = false,
    bool isSingle = false,
    XFile? image,
    int index = 0,
  }) {
    final bool hasContent = image != null ||
        (index < textWidgets.length && textWidgets[index] != null);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Réduit de 16 à 8
      ),
      elevation: 4,
      child: Stack(
        // Retiré le fit: StackFit.expand pour permettre un positionnement naturel
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10), // Réduit de 16 à 8
            child: GestureDetector(
              onTap: () => onImageChange?.call(index), // Utiliser l'index passé
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF2C2C54), // Teinte sombre du dégradé
                      Color(0xFF4B6CB7), // Teinte légèrement plus claire
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: Colors.grey.shade800, width: 0.5),
                  borderRadius: BorderRadius.circular(10), // Réduit de 16 à 8
                ),
                child: Center(
                  child: image != null
                      ? Stack(
                          children: [
                            Image.file(
                              File(image.path),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                            Container(
                              width: double.infinity,
                              height: double.infinity,
                              color: imageFilters[index],
                            ),
                          ],
                        )
                      : !hasContent // Modifier cette condition
                          ? Icon(
                              Icons.add_photo_alternate_outlined,
                              size: isSingle ? 50 : 40,
                              color: Colors
                                  .grey.shade300, // Icône avec contraste doux
                            )
                          : null, // Ne rien afficher si il y a du contenu
                ),
              ),
            ),
          ),
          if (showDeleteButton)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: onDelete,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ),
          if (index < textWidgets.length && textWidgets[index] != null)
            Positioned.fill(
              child: textWidgets[index]!,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Column(
        children: [
          // Première rangée avec blocs 1 et 2
          SizedBox(
            height: numberOfBlocs == 2 ? 300 : 200,
            child: Row(
              children: [
                Expanded(
                  child: _buildBloc(
                    isSingle: numberOfBlocs == 2,
                    image: images[0],
                    index: 0,
                  ),
                ),
                const SizedBox(width: 2), // Réduit de 8 à 2
                Expanded(
                  child: _buildBloc(
                    isSingle: numberOfBlocs == 2,
                    image: images[1],
                    index: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2), // Réduit de 8 à 2
          // Deuxième rangée avec bloc 3 (centré) ou blocs 3 et 4
          if (numberOfBlocs >= 3)
            SizedBox(
              height: 200,
              child: numberOfBlocs == 3
                  ? SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: _buildBloc(
                        showDeleteButton: true,
                        image: images[2],
                        index: 2,
                      ),
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: _buildBloc(
                            showDeleteButton: numberOfBlocs == 4 ? false : true,
                            image: images[2],
                            index: 2,
                          ),
                        ),
                        const SizedBox(width: 2), // Réduit de 8 à 2
                        Expanded(
                          child: _buildBloc(
                            showDeleteButton: numberOfBlocs == 4 ? true : false,
                            image: images[3],
                            index: 3,
                          ),
                        ),
                      ],
                    ),
            ),
        ],
      ),
    );
  }
}
