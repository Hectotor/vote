import 'package:flutter/material.dart';

class PollGrid extends StatefulWidget {
  const PollGrid({Key? key}) : super(key: key);

  @override
  State<PollGrid> createState() => _PollGridState();
}

class _PollGridState extends State<PollGrid> {
  // Palette de couleurs pastel
  final List<Color> pastelColors = [
    Color(0xFFFFC3A0), // Pêche
    Color(0xFFA0E7E5), // Bleu-vert
    Color(0xFFB4F8C8), // Vert menthe
    Color(0xFFFBE7C6), // Jaune crème
    Color(0xFFFFA0A0), // Rose pâle
    Color(0xFFC3B1E1), // Lavande
    Color(0xFFD4F0F0), // Bleu glacier
    Color(0xFFFFC6FF), // Rose bonbon pâle
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
            itemCount: pastelColors.length,
            itemBuilder: (context, colorIndex) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _blockColors[index] = pastelColors[colorIndex];
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  width: 60,
                  height: 60,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: pastelColors[colorIndex],
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
    return GestureDetector(
      onLongPress: () => _showColorPicker(index),
      child: Container(
        height: 100,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: _blockColors[index] ?? Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[800]!),
        ),
        child: Stack(
          children: [
            Center(
              child: TextField(
                controller: _controllers[index],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Option ${index + 1}',
                  hintStyle: TextStyle(
                    color: Colors.grey[600],
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  isDense: true,
                ),
                maxLength: 30,
                buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                textAlignVertical: TextAlignVertical.center,
              ),
            ),
            if (index >= 2)
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => _removeOption(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close, 
                      color: Colors.grey[300], 
                      size: 20
                    ),
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
    return Column(
      children: [
        // Première ligne : blocs 1 et 2
        Row(
          children: [
            Expanded(child: _buildPollOption(0)),
            Expanded(child: _buildPollOption(1)),
          ],
        ),
        const SizedBox(height: 8),
        
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
