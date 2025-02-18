import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class BlocGrid extends StatefulWidget {
  final List<XFile?> images;
  final List<Color> imageFilters;
  final List<Widget?> textWidgets;
  final Function(int) onImageChange;
  final int numberOfBlocs;
  final List<bool> isEditing;

  const BlocGrid({
    Key? key,
    required this.images,
    required this.imageFilters,
    required this.textWidgets,
    required this.onImageChange,
    required this.numberOfBlocs,
    required this.isEditing,
  }) : super(key: key);

  @override
  State<BlocGrid> createState() => _BlocGridState();
}

class _BlocGridState extends State<BlocGrid> {
  List<TextEditingController> _textControllers = [];

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

  Widget _buildBloc({
    bool isSingle = false,
    XFile? image,
    int index = 0,
  }) {
    return Card(
      child: ClipRRect(
        borderRadius: widget.numberOfBlocs >= 2
            ? (index == 0
                ? BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  )
                : index == 1
                    ? BorderRadius.only(
                        topRight: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      )
                    : BorderRadius.circular(16))
            : BorderRadius.circular(16),
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
          ),
          child: Stack(
            children: [
              GestureDetector(
                onTap: () => widget.onImageChange(index),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: image != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(
                              File(image.path),
                              fit: BoxFit.cover,
                            ),
                            Container(
                              color: widget.imageFilters[index],
                            ),
                          ],
                        )
                      : Icon(
                          Icons.add_photo_alternate_outlined,
                          size: isSingle ? 50 : 40,
                          color: Colors.grey.shade300,
                        ),
                ),
              ),
              
              // Zone de texte en mode édition
              if (widget.isEditing[index])
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: widget.textWidgets[index] != null || _textControllers[index].text.isNotEmpty
                          ? LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.0),
                                Colors.black.withOpacity(0.8),
                              ],
                            )
                          : null,
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _textControllers[index],
                      autofocus: true,
                      textAlign: TextAlign.center,
                      textCapitalization: TextCapitalization.sentences,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      cursorColor: Colors.white,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (value) {
                        if (value.isEmpty) {
                          setState(() {
                            widget.textWidgets[index] = null;
                          });
                        } else {
                          setState(() {
                            widget.textWidgets[index] = Text(
                              value,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.visible,
                            );
                          });
                        }
                      },
                    ),
                  ),
                ),
              
              // Afficher le texte existant
              if (!widget.isEditing[index] && widget.textWidgets[index] != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.0),
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: widget.textWidgets[index]!,
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
    return Container(
      color: Colors.transparent,
      child: Column(
        children: [
          SizedBox(
            height: 300,
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => widget.onImageChange(0),
                    child: _buildBloc(
                      isSingle: true,
                      image: widget.images[0],
                      index: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                Expanded(
                  child: GestureDetector(
                    onTap: () => widget.onImageChange(1),
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
