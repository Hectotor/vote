import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../ADD/texte.dart';
import '../ADD/addoption.dart';

class PollGridHome extends StatefulWidget {
  final List<String?> images; // Accepte uniquement les URLs d'images
  final List<Color> imageFilters;
  final int numberOfBlocs;
  final List<TextEditingController> textControllers;
  final Function(int) onImageChange;
  final Function(int) onBlocRemoved;
  final VoidCallback? onStateUpdate;

  const PollGridHome({
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
  State<PollGridHome> createState() => _PollGridHomeState();
}

class _PollGridHomeState extends State<PollGridHome> {
  List<bool> _isTextVisible = [];

  final List<Color> vibrantGradients = [
    Color(0xFF2C2730),   // Deep Navy
    Color(0xFF2C2730),   // Dark Midnight Blue
    Color(0xFF2C2730),   // Rich Indigo
    Color(0xFF2C2730)    // Bright Indigo
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
  void didUpdateWidget(PollGridHome oldWidget) {
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
      builder: (BuildContext dialogContext) {
        return AddOption(
          hasImage: widget.images[index] != null,
          onAddPhoto: (image, filterColor) {
            Navigator.of(dialogContext).pop();
            if (mounted) {
              setState(() {
                widget.images[index] = image.path;
                widget.imageFilters[index] = filterColor;
              });
              widget.onImageChange(index);
              widget.onStateUpdate?.call();
            }
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
              color: Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0, 4),
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
                      child: CachedNetworkImage(
                        imageUrl: widget.images[index]!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
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
                  onVisibilityChanged: (visible) {
                    setState(() {
                      _isTextVisible[index] = visible;
                    });
                  },
                ),
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
        if (widget.numberOfBlocs <= 2) {
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
            itemCount: widget.numberOfBlocs,
            itemBuilder: (context, index) {
              return _buildBloc(index);
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
                      child: _buildBloc(0),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: _buildBloc(1),
                    ),
                  ),
                ],
              ),
              //SizedBox(height: 2), // Réduit l'espace entre les rangées
              // Deuxième rangée (blocs 3 et 4)
              if (widget.numberOfBlocs == 3)
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
                            child: _buildBloc(2),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              else if (widget.numberOfBlocs == 4)
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: _buildBloc(2),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: _buildBloc(3),
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
}
