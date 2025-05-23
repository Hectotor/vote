import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'texte.dart';
import 'addoption.dart';
import 'image.dart';  // Import pour ImageFilterPage

class PollGrid extends StatefulWidget {
  final List<XFile?> images;
  final List<Color> imageFilters;
  final int numberOfBlocs;
  final List<TextEditingController> textControllers;
  final Function(int) onImageChange;
  final Function(int) onBlocRemoved;
  final VoidCallback? onStateUpdate;

  const PollGrid({
    Key? key,
    required this.images,
    required this.imageFilters,
    required this.numberOfBlocs,
    required this.textControllers,
    required this.onImageChange,
    required this.onBlocRemoved,
    this.onStateUpdate,
  }) : super(key: key);

  static double getBlockRatio(BuildContext context) {
    return 100; // Remplacer par la logique pour obtenir le ratio
  }

  @override
  State<PollGrid> createState() => _PollGridState();
}

class _PollGridState extends State<PollGrid> {
  List<bool> _isTextVisible = [];

  // Couleur de fond sombre pour les blocs
  final Color backgroundColor = Color(0xFF1B202A);  // Couleur sombre

  // Couleur pour les icônes et textes
  Color _getIconColor() {
    return Colors.white;  // Blanc pour contraster avec le fond sombre
  }

  @override
  void initState() {
    super.initState();
    _isTextVisible = List.generate(widget.numberOfBlocs, (index) => false);
  }

  @override
  void didUpdateWidget(PollGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.numberOfBlocs > oldWidget.numberOfBlocs) {
      setState(() {
        _isTextVisible.add(false);
      });
    }
  }

  void _showAddOptionDialog(int index) {
    // Créer un BuildContext local pour la navigation
    final BuildContext currentContext = context;
    
    showModalBottomSheet(
      context: currentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext dialogContext) {
        return AddOption(
          hasImage: widget.images[index] != null,
          onAddPhoto: (XFile image, Color filterColor) async {
            // Fermer le dialogue d'abord
            Navigator.of(dialogContext).pop();
            
            // Utiliser le contexte du widget parent pour la navigation vers ImageFilterPage
            if (!mounted) return;
            
            await Navigator.push(
              currentContext,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => ImageFilterPage(
                  image: image,
                  onFilterSelected: (filteredImage, color) {
                    // Mettre à jour l'état du widget parent
                    if (mounted) {
                      setState(() {
                        widget.images[index] = filteredImage;
                        widget.imageFilters[index] = color;
                      });
                      
                      // Appeler le callback de changement d'image
                      widget.onImageChange(index);
                      
                      // Trigger state update if callback is provided
                      widget.onStateUpdate?.call();
                    }
                  },
                ),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          },
          onTakePhoto: (XFile image, Color filterColor) async {
            // Fermer le dialogue d'abord
            Navigator.of(dialogContext).pop();
            
            // Utiliser le contexte du widget parent pour la navigation vers ImageFilterPage
            if (!mounted) return;
            
            await Navigator.push(
              currentContext,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => ImageFilterPage(
                  image: image,
                  onFilterSelected: (filteredImage, color) {
                    // Mettre à jour l'état du widget parent
                    if (mounted) {
                      setState(() {
                        widget.images[index] = filteredImage;
                        widget.imageFilters[index] = color;
                      });
                      
                      // Appeler le callback de changement d'image
                      widget.onImageChange(index);
                      
                      // Trigger state update if callback is provided
                      widget.onStateUpdate?.call();
                    }
                  },
                ),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          },
          onRemoveImage: widget.images[index] != null
              ? () {
                  Navigator.of(dialogContext).pop();
                  if (mounted) {
                    setState(() {
                      widget.images[index] = null;
                      widget.imageFilters[index] = Colors.transparent;
                      widget.onImageChange(index);
                      widget.onStateUpdate?.call();
                    });
                  }
                }
              : null,
        );
      },
    );
  }

  Widget _buildBloc(int index) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Calculer la largeur du bloc en fonction du nombre de colonnes (comme dans poll_grid_display.dart)
    final blockWidth = (screenWidth - 20.0 - 8.0) / 2; // 10px de marge de chaque côté + 8px d'espacement
    final blockHeight = blockWidth; // Aspect ratio 1:1 pour des blocs carrés
    
    // Nous utilisons maintenant un contour au lieu d'une couleur de fond

    return GestureDetector(
      onTap: () => _showAddOptionDialog(index),
      child: Container(
        width: blockWidth,
        height: blockHeight, 
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            widget.images[index] != null
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: Image.file(
                        File(widget.images[index]!.path),
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    if (widget.imageFilters[index] != Colors.transparent)
                      Container(
                        decoration: BoxDecoration(
                          color: widget.imageFilters[index],
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                  ],
                )
              : Center(
                  child: IconButton(
                    icon: Icon(
                      Icons.add_photo_alternate_outlined, 
                      size: 40, 
                      color: _getIconColor().withOpacity(0.7),
                    ),
                    onPressed: () => _showAddOptionDialog(index),
                  ),
                ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: () => _showAddOptionDialog(index),
                child: TexteWidget(
                  controller: widget.textControllers[index],
                  isVisible: _isTextVisible[index],
                  onVisibilityChanged: (bool visible) {
                    setState(() {
                      _isTextVisible[index] = visible;
                    });
                  },
                ),
              ),
            ),
            if (index >= 2) // Pour les blocs 3 et 4
              Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                  icon: Icon(Icons.close_sharp, color: _getIconColor()),
                  onPressed: () {
                    // Vérifier que l'index est valide avant la suppression
                     if (index >= 2 && index < widget.textControllers.length) {
                       widget.onBlocRemoved(index);
                     }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final blockWidth = (screenWidth - 20.0 - 8.0) / 2; // 10px de marge de chaque côté + 8px d'espacement
        
        if (widget.textControllers.length <= 2) {
          // Pour les 2 premiers blocs, utiliser GridView normal
          return SizedBox(
            height: blockWidth, // Hauteur égale à la largeur pour un ratio 1:1
            child: GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.0, // Ratio 1:1 pour des blocs carrés
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              padding: const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10), // Mêmes marges que dans poll_grid_display.dart
              itemCount: widget.textControllers.length,
              itemBuilder: (context, index) => _buildBloc(index),
            ),
          );
        } else if (widget.textControllers.length == 3) {
          // Pour 3 blocs, utiliser la disposition 'triple' comme dans poll_grid_display.dart
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
                        child: _buildBloc(0),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: _buildBloc(1),
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
                        width: MediaQuery.of(context).size.width / 2.3, // Taille identique à poll_grid_display.dart
                        height: MediaQuery.of(context).size.width / 2.3, // Hauteur identique à la largeur pour maintenir le ratio 1:1
                        child: _buildBloc(2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          // Pour 4 blocs ou plus, utiliser un GridView standard avec 2 colonnes
          return Container(
            margin: const EdgeInsets.only(bottom: 0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.0, // Garantit que les blocs sont carrés
              ),
              padding: const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),

              itemCount: widget.textControllers.length,
              itemBuilder: (context, index) => AspectRatio(
                aspectRatio: 1.0,
                child: _buildBloc(index),
              ),
            ),
          );
        }
      },
    );
  }
}