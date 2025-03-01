import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'texte.dart';
import 'addoption.dart';

class PollGrid extends StatefulWidget {
  final List<XFile?> images;
  final List<Color> imageFilters;
  final int numberOfBlocs;
  final List<TextEditingController> textControllers;
  final Function(int) onImageChange;
  final Function(int) onBlocRemoved;

  const PollGrid({
    Key? key,
    required this.images,
    required this.imageFilters,
    required this.numberOfBlocs,
    required this.textControllers,
    required this.onImageChange,
    required this.onBlocRemoved,
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
    Color(0xFF352F3A),
    Color(0xFF352F3A),
    Color(0xFF352F3A),
    Color(0xFF352F3A)
  ];

  final List<String> optionEmojis = [
    '', // Célébration
    '', // Fusée
    '', // Arc-en-ciel
    '', // Guitare,
  ];

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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddOption(
          hasImage: widget.images[index] != null,
          onAddPhoto: () {
            Navigator.of(context).pop();
            widget.onImageChange(index);
          },
          onTakePhoto: () {
            Navigator.of(context).pop();
            // TODO: Implement take photo functionality
          },
          onAddText: () {
            Navigator.of(context).pop();
            setState(() {
              _isTextVisible[index] = true;
            });
          },
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

    return GestureDetector(
      onTap: () => _showAddOptionDialog(index),
      child: Container(
        width: blockWidth,
        height: 145.0, // hauteur réduite du bloc
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: IconButton(
                icon: Icon(
                  Icons.add_photo_alternate_outlined, 
                  size: 40, 
                  color: Colors.white.withOpacity(0.7),
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
                  icon: Icon(Icons.close_sharp, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      widget.textControllers.removeAt(index);
                      _isTextVisible.removeAt(index);
                      widget.onBlocRemoved(index);
                    });
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
            height: 145.0,
            child: GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: (constraints.maxWidth - 8.0) / (2 * 145.0),
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
            height: widget.textControllers.length == 3 ? 298.0 : 298.0, // 145 * 2 + 8 (spacing)
            child: Column(
              children: [
                // Première rangée (blocs 1 et 2)
                Row(
                  children: [
                    Expanded(child: _buildBloc(0)),
                    SizedBox(width: 8),
                    Expanded(child: _buildBloc(1)),
                  ],
                ),
                SizedBox(height: 8),
                // Deuxième rangée (blocs 3 et 4)
                if (widget.textControllers.length == 3)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Center(
                          child: SizedBox(
                            width: (constraints.maxWidth - 8.0) / 2, // Largeur identique aux autres blocs
                            height: 145.0, // Hauteur identique aux autres blocs
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
                      SizedBox(width: 8),
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