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

  final List<Color> vibrantGradients = [
    Color(0xF5F5F5F5),   // Deep Navy
    Color(0xF5F5F5F5),   // Dark Midnight Blue
    Color(0xF5F5F5F5),   // Rich Indigo
    Color(0xF5F5F5F5)    // Bright Indigo
  ];

  List<Color> _getColors() {
    return [
      Colors.blue,
      Colors.purple,
      Colors.orange,
      Colors.green,
    ];
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
    final blockWidth = (screenWidth - 24.0 - 8.0) / 2;
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        vibrantGradients[index % vibrantGradients.length],
        vibrantGradients[index % vibrantGradients.length].withOpacity(0.7),
      ],
    );

    final colors = _getColors();
    final color = colors[index % colors.length];

    return GestureDetector(
      onTap: () => _showAddOptionDialog(index),
      child: Container(
        width: blockWidth,
        height: 200.0, 
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
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
                      color: color.withOpacity(0.7),
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
                  icon: Icon(Icons.close_sharp, color: color),
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
        if (widget.textControllers.length <= 2) {
          // Pour les 2 premiers blocs, utiliser GridView normal
          return SizedBox(
            height: 200.0,
            child: GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: (constraints.maxWidth - 8.0) / (2 * 200.0),
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: widget.textControllers.length,
              itemBuilder: (context, index) => _buildBloc(index),
            ),
          );
        } else {
          // Pour 3 ou 4 blocs, utiliser une disposition uniforme
          return SizedBox(
            height: widget.textControllers.length == 3 ? 416.0 : 416.0, // 200 * 2 + 8 (spacing) + 8 (padding)
            child: Column(
              children: [
                // Première rangée (blocs 1 et 2)
                Row(
                  children: [
                    Expanded(child: _buildBloc(0)),
                    SizedBox(width: 10),
                    Expanded(child: _buildBloc(1)),
                  ],
                ),
                SizedBox(height: 10),
                // Deuxième rangée (blocs 3 et 4)
                if (widget.textControllers.length == 3)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Center(
                          child: SizedBox(
                            width: (constraints.maxWidth - 8.0) / 2, // Largeur identique aux autres blocs
                            height: 200.0, // Hauteur identique aux autres blocs
                            child: _buildBloc(2),
                          ),
                        ),
                      ),
                    ],
                  )
                else if (widget.textControllers.length == 4)
                  Row(
                    children: [
                      Expanded(child: _buildBloc(2)),
                      SizedBox(width: 10),
                      Expanded(child: _buildBloc(3)),
                    ],
                  )
              ],
            ),
          );
        }
      },
    );
  }
}