import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class BlocGrid extends StatefulWidget {
  final List<XFile?> images;
  final Function(int) onImageChange;
  final List<Color> imageFilters;
  final List<Widget?> textWidgets;
  final List<bool> isEditing;
  final int numberOfBlocs;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onOpenAddOption;

  const BlocGrid({
    Key? key,
    required this.images,
    required this.onImageChange,
    required this.imageFilters,
    required this.textWidgets,
    required this.isEditing,
    this.numberOfBlocs = 2,
    this.onTap,
    this.onDelete,
    this.onOpenAddOption,
  }) : super(key: key);

  @override
  _BlocGridState createState() => _BlocGridState();
}

class _BlocGridState extends State<BlocGrid> {
  late List<TextEditingController> _textControllers;
  late List<bool> _isEditing;

  @override
  void initState() {
    super.initState();
    _textControllers = List.generate(
      widget.images.length, 
      (_) => TextEditingController()
    );
    _isEditing = widget.isEditing;
  }

  void _activateTextEdit(int index) {
    setState(() {
      // Conserver l'état du texte pour tous les blocs
      for (int i = 0; i < _isEditing.length; i++) {
        if (i != index && _textControllers[i].text.isNotEmpty) {
          // Créer un widget texte pour les blocs non édités qui ont du contenu
          widget.textWidgets[i] = Text(
            _textControllers[i].text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          );
        }
        // Désactiver l'édition pour tous les autres blocs
        _isEditing[i] = (i == index);
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _textControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildBloc({
    bool isSingle = false,
    XFile? image,
    int index = 0,
  }) {
    return Card(
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: widget.numberOfBlocs >= 2
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
              onTap: () {
                // Réinitialiser tous les modes d'édition avant de changer l'image
                setState(() {
                  _isEditing = List.filled(_isEditing.length, false);
                });
                // Appeler le changement d'image
                widget.onImageChange.call(index);
              },
              onDoubleTap: () {
                // Activer la zone de texte uniquement pour ce bloc
                _activateTextEdit(index);
              },
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
                  borderRadius: widget.numberOfBlocs >= 2
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
                              color: widget.imageFilters[index],
                            ),
                          ],
                        )
                      : !(_isEditing[index] || (index < widget.textWidgets.length && widget.textWidgets[index] != null))
                          ? Icon(
                              Icons.add_photo_alternate_outlined,
                              size: isSingle ? 50 : 40,
                              color: Colors.grey.shade300,
                            )
                          : null,
                ),
              ),
            ),
          ),
          
          // Afficher le texte existant si non édité
          if (!_isEditing[index] && widget.textWidgets[index] != null)
            Positioned.fill(
              child: Center(
                child: widget.textWidgets[index]!,
              ),
            ),
          
          // Zone de texte en mode édition
          if (_isEditing[index])
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  // Ouvrir AddOption sans modifier l'état d'édition
                  widget.onOpenAddOption?.call();
                },
                child: Container(
                  color: Colors.transparent,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {}, 
                      child: TextField(
                        controller: _textControllers[index],
                        autofocus: true,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          height: 1.5,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                        cursorColor: Colors.white,
                        keyboardType: TextInputType.multiline,
                        minLines: 1,
                        maxLines: null,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (value) {
                          // Fermer le clavier et conserver le texte
                          FocusScope.of(context).unfocus();
                          setState(() {
                            // Créer un widget texte permanent
                            widget.textWidgets[index] = Text(
                              value,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            );
                            // Désactiver le mode édition
                            _isEditing[index] = false;
                          });
                        },
                        onChanged: (value) {
                          setState(() {
                            // Mettre à jour dynamiquement le texte
                            widget.textWidgets[index] = Text(
                              value,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            );
                          });
                        },
                        onEditingComplete: () {
                          // Fermer le clavier et conserver le texte
                          FocusScope.of(context).unfocus();
                          setState(() {
                            widget.textWidgets[index] = Text(
                              _textControllers[index].text,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            );
                            // Désactiver le mode édition
                            _isEditing[index] = false;
                          });
                        },
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
                  child: GestureDetector(
                    onDoubleTap: () => _activateTextEdit(0),
                    child: _buildBloc(
                      isSingle: true,
                      image: widget.images[0],
                      index: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 2), // Réduit de 8 à 2
                Expanded(
                  child: GestureDetector(
                    onDoubleTap: () => _activateTextEdit(1),
                    child: _buildBloc(
                      isSingle: true,
                      image: widget.images[1],
                      index: 1,
                    ),
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
