import 'package:flutter/material.dart';

class PollGrid extends StatefulWidget {
  final int numberOfBlocs;
  final List<TextEditingController> textControllers;
  final Function(int) onBlocRemoved;

  const PollGrid({
    Key? key,
    required this.numberOfBlocs,
    required this.textControllers,
    required this.onBlocRemoved,
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
Color(0xFF2C2730),
Color(0xFF2C2730),
Color(0xFF2C2730),
Color(0xFF2C2730)
  ];

  final List<String> optionEmojis = [
    '', // Célébration
    '', // Fusée
    '', // Arc-en-ciel
    '', // Guitare
  ];


  @override
  void initState() {
    super.initState();
    _textControllers = List.generate(
      widget.numberOfBlocs,
      (index) => TextEditingController(),
    );
  }

  @override
  void didUpdateWidget(PollGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.numberOfBlocs > oldWidget.numberOfBlocs) {
      setState(() {
        _textControllers.add(TextEditingController());
      });
    }
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
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black45,
                      offset: Offset(2.0, 2.0),
                    ),
                  ],
                ),
                textInputAction: TextInputAction.done,
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
                maxLength: 20,
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
                    widget.onBlocRemoved(index);
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
    return LayoutBuilder(
      builder: (context, constraints) {
        if (_textControllers.length <= 2) {
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
              itemCount: _textControllers.length,
              itemBuilder: (context, index) => _buildBloc(index),
            ),
          );
        } else {
          // Pour 3 ou 4 blocs, utiliser une disposition personnalisée
          return SizedBox(
            height: _textControllers.length == 3 ? 298.0 : 298.0, // 145 * 2 + 8 (spacing)
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
                else if (_textControllers.length == 4)
                  Row(
                    children: [
                      Expanded(child: _buildBloc(2)),
                      SizedBox(width: 8),
                      Expanded(child: _buildBloc(3)),
                    ],
                  ),
              ],
            ),
          );
        }
      },
    );
  }
}