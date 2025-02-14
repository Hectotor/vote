import 'package:flutter/material.dart';

class TextEditWidget extends StatefulWidget {
  final Color backgroundColor;
  final VoidCallback? onEmpty;
  final String initialText; // Ajouter cette ligne

  const TextEditWidget({
    Key? key,
    required this.backgroundColor,
    this.onEmpty,
    this.initialText = '', // Ajouter cette ligne
  }) : super(key: key);

  @override
  State<TextEditWidget> createState() => _TextEditWidgetState();
}

class _TextEditWidgetState extends State<TextEditWidget> {
  final TextEditingController _textController = TextEditingController();
  late Offset _position;
  String _displayText = '';
  final GlobalKey _parentKey = GlobalKey();
  Size _parentSize = Size.zero;
  double _fontSize = 16.0; // Nouvelle variable pour la taille du texte
  Offset? _startPosition; // Nouvelle variable pour le point de départ
  bool _dialogOpen = false; // Ajouter cette variable
  bool _isDragging = false; // Nouvelle variable pour suivre l'état du drag

  @override
  void initState() {
    super.initState();
    print('TextEditWidget - initState called');
    _textController.text = widget.initialText; // Ajouter cette ligne
    // Retarder l'initialisation pour éviter les problèmes de contexte
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Vérifier si le widget est toujours monté
        print('TextEditWidget - postFrameCallback');
        _initializePosition();
        _showTextDialog();
      }
    });
  }

  void _initializePosition() {
    if (_parentKey.currentContext != null) {
      final RenderBox box =
          _parentKey.currentContext!.findRenderObject() as RenderBox;
      _parentSize = box.size;
      _position = Offset(
        _parentSize.width / 2 - 50, // Centré horizontalement
        _parentSize.height / 2 - 10, // Centré verticalement
      );
    }
  }

  void _showTextDialog() {
    print('TextEditWidget - _showTextDialog called');
    _dialogOpen = true; // Marquer que le dialog est ouvert
    double tempFontSize = _fontSize; // Variable temporaire pour la taille
    String tempText = _textController.text; // Sauvegarder le texte actuel

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // Ajout de StatefulBuilder pour mettre à jour l'UI du dialog
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color(0xFF1D1D2C),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 0.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: _textController,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize:
                              tempFontSize, // Utiliser la taille temporaire
                        ),
                        textCapitalization: TextCapitalization
                            .sentences, // Ajout de cette ligne
                        decoration: const InputDecoration(
                          hintText: "Texte...",
                          hintStyle: TextStyle(color: Colors.white70),
                          border: InputBorder.none,
                        ),
                        textAlign: TextAlign.center, // Centrer le texte
                        //maxLines: 3,
                        autofocus: true, // Ajouter ceci pour focus automatique
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Ajout du curseur de taille
                    Row(
                      children: [
                        const Icon(Icons.text_fields,
                            color: Colors.white70, size: 20),
                        Expanded(
                          child: Slider(
                            value: tempFontSize,
                            min: 12.0,
                            max: 32.0,
                            divisions: 20,
                            activeColor: const Color(0xFF4B6CB7),
                            inactiveColor: Colors.white24,
                            onChanged: (value) {
                              setDialogState(() {
                                tempFontSize = value;
                              });
                            },
                          ),
                        ),
                        Text(
                          tempFontSize.round().toString(),
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            _textController.text =
                                tempText; // Restaurer le texte original
                            if (_displayText.isEmpty &&
                                widget.onEmpty != null) {
                              widget
                                  .onEmpty!(); // Supprimer le widget si pas de texte
                            }
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Annuler',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _displayText = _textController.text;
                              _fontSize =
                                  tempFontSize; // Mettre à jour la taille finale
                              if (_displayText.isEmpty &&
                                  widget.onEmpty != null) {
                                widget.onEmpty!();
                              }
                            });
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4B6CB7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      if (mounted) {
        setState(() {
          _dialogOpen = false; // Marquer que le dialog est fermé
        });
      }
    });
  }

  void _updatePosition(Offset delta) {
    if (_parentKey.currentContext != null) {
      final RenderBox box =
          _parentKey.currentContext!.findRenderObject() as RenderBox;
      final Size size = box.size;

      setState(() {
        // Calcul des nouvelles coordonnées
        final newX = _position.dx + delta.dx;
        final newY = _position.dy + delta.dy;

        // Marges de sécurité
        const margin = 10.0;

        // Contraintes avec marges
        _position = Offset(
          newX.clamp(margin, size.width - margin * 2),
          newY.clamp(margin, size.height - margin * 2),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _parentKey,
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          if (_displayText.isNotEmpty)
            Positioned(
              left: _position.dx,
              top: _position.dy,
              child: GestureDetector(
                onPanStart: (details) {
                  setState(() {
                    _isDragging = true; // Début du drag
                    _startPosition = details.globalPosition;
                  });
                },
                onPanUpdate: (details) {
                  if (_startPosition != null) {
                    final delta = details.globalPosition - _startPosition!;
                    _updatePosition(delta);
                    _startPosition = details.globalPosition;
                  }
                },
                onPanEnd: (_) {
                  setState(() {
                    _isDragging = false; // Fin du drag
                    _startPosition = null;
                  });
                },
                onTap: _showTextDialog,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: _parentSize.width * 0.8,
                    minWidth: 50,
                  ),
                  child: Opacity(
                    opacity: _isDragging ? 0.7 : 1.0, // Ajout de l'opacité
                    child: Text(
                      _displayText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: _fontSize,
                        fontWeight: FontWeight.bold,
                        shadows: const [
                          Shadow(
                            offset: Offset(1, 1),
                            blurRadius: 3.0,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    print('TextEditWidget - dispose called');
    if (_dialogOpen) {
      // Si le dialog est ouvert, le fermer
      Navigator.of(context, rootNavigator: true).pop();
    }
    _textController.dispose();
    super.dispose();
  }
}
