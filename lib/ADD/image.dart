import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class ImageFilterPage extends StatefulWidget {
  final XFile image;
  final Function(XFile, Color) onFilterSelected;

  const ImageFilterPage({
    Key? key,
    required this.image,
    required this.onFilterSelected,
  }) : super(key: key);

  @override
  State<ImageFilterPage> createState() => _ImageFilterPageState();
}

class _ImageFilterPageState extends State<ImageFilterPage> {
  Color _selectedFilter = Colors.transparent;
  bool isGif = false;
  final List<Color> _filterColors = [
    Colors.transparent,
    Colors.blue.withOpacity(0.3),
    Colors.red.withOpacity(0.3),
    Colors.green.withOpacity(0.3),
    Colors.purple.withOpacity(0.3),
    Colors.amber.withOpacity(0.3),
    Colors.pink.withOpacity(0.3),
    Colors.teal.withOpacity(0.3),
  ];

  @override
  void initState() {
    super.initState();
    isGif = widget.image.path.toLowerCase().endsWith('.gif');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              widget.onFilterSelected(widget.image, _selectedFilter);
              Navigator.of(context).pop();
            },
            child:
                const Text('Appliquer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Image.file(
                      File(widget.image.path),
                      fit: BoxFit.contain,
                    ),
                    Positioned.fill(
                      child: Container(color: _selectedFilter),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            height: 120,
            color: Colors.black54,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              itemCount: _filterColors.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFilter = _filterColors[index];
                    });
                  },
                  child: Container(
                    width: 80,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedFilter == _filterColors[index]
                            ? Colors.white
                            : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(
                            File(widget.image.path),
                            fit: BoxFit.cover,
                          ),
                          Container(color: _filterColors[index]),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}

// Fonction addPhoto modifiée pour gérer les GIFs
Future<void> addPhoto(int index, List<XFile?> images, Function setState,
    BuildContext context, Function(int, Color) onFilterChange) async {
  if (!context.mounted) return;

  final picker = ImagePicker();
  final XFile? pickedFile = await picker.pickImage(
    source: ImageSource.gallery,
  );

  if (pickedFile != null && context.mounted) {
    if (pickedFile.path.toLowerCase().endsWith('.gif')) {
      setState(() {
        images[index] = pickedFile;
      });
      onFilterChange(index, Colors.transparent);
    } else {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Recadrer l\'image',
            toolbarColor: const Color(0xFF1D1D2C),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Recadrer l\'image',
            doneButtonTitle: 'Terminer',
            cancelButtonTitle: 'Annuler',
            aspectRatioLockEnabled: true,
          ),
        ],
      );

      if (croppedFile != null && context.mounted) {
        final imageFile = XFile(croppedFile.path);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ImageFilterPage(
              image: imageFile,
              onFilterSelected: (image, filterColor) {
                setState(() {
                  images[index] = image;
                });
                onFilterChange(index, filterColor);
              },
            ),
          ),
        );
      }
    }
  }
}

Future<void> takePhoto(int index, List<XFile?> images, Function setState,
    BuildContext context, Function(int, Color) onFilterChange) async {
  // Ajout du paramètre onFilterChange
  if (!context.mounted) return; // Vérifiez si le contexte est monté

  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.camera);

  if (pickedFile != null && context.mounted) {
    // Vérifiez encore après l'opération async
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Recadrer la photo',
          toolbarColor: const Color(0xFF1D1D2C),
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
          hideBottomControls: false,
        ),
        IOSUiSettings(
          title: 'Recadrer la photo',
          doneButtonTitle: 'Terminer',
          cancelButtonTitle: 'Annuler',
          aspectRatioLockEnabled: true,
        ),
      ],
    );

    if (croppedFile != null && context.mounted) {
      // Vérifiez encore après le crop
      final imageFile = XFile(croppedFile.path);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ImageFilterPage(
            image: imageFile,
            onFilterSelected: (XFile image, Color filterColor) {
              setState(() {
                images[index] = image;
              });
              onFilterChange(index, filterColor); // Utiliser la fonction passée
            },
          ),
        ),
      );
    }
  } else {
    print('No photo taken'); // Debug print
  }
}
