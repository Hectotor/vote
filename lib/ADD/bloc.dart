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
        borderRadius: numberOfBlocs >= 2
          ? (index == 0 
              ? BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16)
                )
              : index == 1
                ? BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16)
                  )
              : index == 2
                ? BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16)
                  )
                : index == 3
                  ? BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(16)
                    )
                  : BorderRadius.circular(16))
          : BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: numberOfBlocs >= 2
              ? (index == 0 
                  ? BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16)
                    )
                  : index == 1
                    ? BorderRadius.only(
                        topRight: Radius.circular(16),
                        bottomRight: Radius.circular(16)
                      )
                  : index == 2
                    ? BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16)
                      )
                    : index == 3
                      ? BorderRadius.only(
                          topRight: Radius.circular(16),
                          bottomRight: Radius.circular(16)
                        )
                      : BorderRadius.circular(16))
              : BorderRadius.circular(16),
            child: GestureDetector(
              onTap: () => onImageChange?.call(index),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF2C2C54),
                      Color(0xFF4B6CB7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: Colors.grey.shade800, width: 0.5),
                  borderRadius: numberOfBlocs >= 2
                    ? (index == 0 
                        ? BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomLeft: Radius.circular(16)
                          )
                        : index == 1
                          ? BorderRadius.only(
                              topRight: Radius.circular(16),
                              bottomRight: Radius.circular(16)
                            )
                          : index == 2
                            ? BorderRadius.only(
                                topLeft: Radius.circular(16),
                                bottomLeft: Radius.circular(16)
                              )
                            : index == 3
                              ? BorderRadius.only(
                                  topRight: Radius.circular(16),
                                  bottomRight: Radius.circular(16)
                                )
                              : BorderRadius.circular(16))
                    : BorderRadius.circular(16),
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
            height: 300,
            child: Row(
              children: [
                Expanded(
                  child: _buildBloc(
                    isSingle: true,
                    image: images[0],
                    index: 0,
                  ),
                ),
                const SizedBox(width: 2), // Réduit de 8 à 2
                Expanded(
                  child: _buildBloc(
                    isSingle: true,
                    image: images[1],
                    index: 1,
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
