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

  static double getBlockRatio(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = 24.0; // 12 de chaque côté
    final spaceBetweenBlocks = 8.0;
    final blockWidth = (screenWidth - horizontalPadding - spaceBetweenBlocks) / 2;
    final blockHeight = 300.0;
    return blockWidth / blockHeight;
  }

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

  // Palette de couleurs vibrantes et modernes
final List<Color> vibrantGradients = [
  Color(0xFF2C2730), // Gris foncé
  Color(0xFF2C2730),
];

  // Emojis amusants pour chaque option
  final List<String> optionEmojis = [
    '🎉', // Célébration
    '🚀', // Fusée
    '🌈', // Arc-en-ciel
    '🎸', // Guitare
  ];

  Widget _buildBloc({
    bool isSingle = false,
    XFile? image,
    int index = 0,
  }) {
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
      height: 300.0,
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
          GestureDetector(
            onTap: () => widget.onImageChange(index),
            child: image != null
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: Image.file(
                        File(image.path),
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
                  child: Icon(
                    Icons.add_photo_alternate_outlined,
                    size: isSingle ? 50 : 40,
                    color: Colors.grey.shade200,
                  ),
                ),
          ),
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
                    fontStyle: FontStyle.italic,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  cursorColor: Colors.white,
                  keyboardType: TextInputType.multiline,
                  // maxLength: 30,
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
                            fontStyle: FontStyle.italic,
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
                const SizedBox(width: 8),
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
