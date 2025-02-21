import 'package:flutter/material.dart';

class PollGrid extends StatefulWidget {
  const PollGrid({Key? key}) : super(key: key);

  @override
  State<PollGrid> createState() => _PollGridState();
}

class _PollGridState extends State<PollGrid> {
  // Palette de couleurs vibrantes et modernes
  final List<Color> vibrantGradients = [
    Color(0xFF6A11CB), // Violet profond
    Color(0xFF2575FC), // Bleu électrique
    Color(0xFFFF6B6B), // Corail vif
    Color(0xFF4ECDC4), // Turquoise moderne
  ];

  // Emojis amusants pour chaque option
  final List<String> optionEmojis = [
    '🎉', // Célébration
    '🚀', // Fusée
    '🌈', // Arc-en-ciel
    '🎸', // Guitare
  ];

  // Liste des contrôleurs de texte
  List<TextEditingController> _controllers = [];
  
  // Liste des couleurs pour chaque bloc
  List<Color?> _blockColors = [];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(2, (_) => TextEditingController());
    _blockColors = List.generate(2, (_) => null);
  }

  void _addNewOption() {
    if (_controllers.length < 4) {
      setState(() {
        _controllers.add(TextEditingController());
        _blockColors.add(null);
      });
    }
  }

  void _removeOption(int index) {
    if (index >= 2 && index < _controllers.length) {
      setState(() {
        _controllers.removeAt(index);
        _blockColors.removeAt(index);
      });
    }
  }

  void _showColorPicker(int index) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 100,
          color: Colors.black87,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: vibrantGradients.length,
            itemBuilder: (context, colorIndex) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _blockColors[index] = vibrantGradients[colorIndex];
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  width: 60,
                  height: 60,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: vibrantGradients[colorIndex],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPollOption(int index) {
    // Sélectionner un dégradé unique pour chaque bloc
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        vibrantGradients[index % vibrantGradients.length],
        vibrantGradients[index % vibrantGradients.length].withOpacity(0.7),
      ],
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: 120, // Augmentation de la hauteur verticale
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4), // Réduction de la marge verticale
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onLongPress: () => _showColorPicker(index),
          child: Stack(
            children: [
              Center(
                child: TextField(
                  controller: _controllers[index],
                  textAlign: TextAlign.center,
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

              // Bouton de suppression pour les options 3 et 4
              if (index >= 2)
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _removeOption(index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.close, 
                        color: Colors.white, 
                        size: 20,
                        shadows: [
                          Shadow(
                            blurRadius: 5.0,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Première ligne : blocs 1 et 2
        Row(
          children: [
            Expanded(child: _buildPollOption(0)),
            Expanded(child: _buildPollOption(1)),
          ],
        ),
        // Deuxième ligne : blocs 3 et 4
        if (_controllers.length > 2)
          Row(
            children: [
              if (_controllers.length == 3) ...[
                const Spacer(),
                Expanded(flex: 2, child: _buildPollOption(2)),
                const Spacer(),
              ] else ...[
                Expanded(child: _buildPollOption(2)),
                Expanded(child: _buildPollOption(3)),
              ],
            ],
          ),

        const SizedBox(height: 8),
        
        // Bouton d'ajout
        if (_controllers.length < 4)
          ElevatedButton(
            onPressed: _addNewOption,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[800],
              foregroundColor: Colors.white,
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
                  color: Colors.grey[300]
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
      ],
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
