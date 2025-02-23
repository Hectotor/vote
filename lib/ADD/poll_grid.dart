import 'package:flutter/material.dart';

class PollGrid extends StatefulWidget {
  final int numberOfBlocs;
  final List<TextEditingController> textControllers;

  const PollGrid({
    Key? key,
    required this.numberOfBlocs,
    required this.textControllers,
  }) : super(key: key);

  static double getBlockRatio(BuildContext context) {
    return 100; // Remplacer par la logique pour obtenir le ratio
  }

  @override
  State<PollGrid> createState() => _PollGridState();
}

class _PollGridState extends State<PollGrid> {
  List<TextEditingController> _textControllers = [];

  final List<Color> vibrantGradients = [
    Colors.grey[900]!,
    Colors.grey[900]!,
    Colors.grey[900]!,
    Colors.grey[900]!
  ];

  final List<String> optionEmojis = [
    '🎉', // Célébration
    '🚀', // Fusée
    '🌈', // Arc-en-ciel
    '🎸', // Guitare
  ];

  void _addNewOption() {
    setState(() {
      _textControllers.add(TextEditingController());
    });
  }

  @override
  void initState() {
    super.initState();
    _textControllers = List.generate(
      widget.numberOfBlocs,
      (index) => TextEditingController(),
    );
  }

  @override
  void dispose() {
    for (var controller in _textControllers) {
      controller.dispose();
    }
    super.dispose();
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

    return Container(
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
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _textControllers[index],
                textAlign: TextAlign.center, // Centrer le texte
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black45,
                      offset: Offset(2.0, 2.0),
                    ),
                  ],
                ),
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Option ${index + 1} ${optionEmojis[index % optionEmojis.length]}',
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                maxLength: 30,
                maxLines: null,
                buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
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
                    _textControllers.removeAt(index);
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 370,
      child: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (_textControllers.length <= 2) {
                  // Pour les 2 premiers blocs, utiliser GridView normal
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: (constraints.maxWidth - 8.0) / (2 * 145.0),
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: _textControllers.length,
                    itemBuilder: (context, index) => _buildBloc(index),
                  );
                } else {
                  // Pour 3 ou 4 blocs, utiliser une disposition personnalisée
                  return Column(
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
                      if (_textControllers.length == 3)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: (constraints.maxWidth - 8) / 2,
                              child: _buildBloc(2),
                            ),
                          ],
                        )
                      else
                        Row(
                          children: [
                            Expanded(child: _buildBloc(2)),
                            SizedBox(width: 8),
                            Expanded(child: _buildBloc(3)),
                          ],
                        ),
                    ],
                  );
                }
              },
            ),
          ),
          // Bouton d'ajout
          if (_textControllers.length < 4)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                width: PollGrid.getBlockRatio(context) * 2,
                child: ElevatedButton(
                  onPressed: _addNewOption,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    shadowColor: Colors.black.withOpacity(0.3),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        size: 20,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Add Option',
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}