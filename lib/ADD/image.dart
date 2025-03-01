import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'bloc.dart';

class ImageFilterPage extends StatefulWidget {
  final XFile image;
  final Function(XFile, Color) onFilterSelected;
  final Color initialFilter;

  const ImageFilterPage({
    Key? key,
    required this.image,
    required this.onFilterSelected,
    this.initialFilter = Colors.transparent,
  }) : super(key: key);

  // Méthode statique sécurisée pour naviguer vers la page de filtre
  static Future<void> show({
    required BuildContext context,
    required XFile image,
    required Function(XFile, Color) onFilterSelected,
    Color initialFilter = Colors.transparent,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ImageFilterPage(
          image: image,
          onFilterSelected: onFilterSelected,
          initialFilter: initialFilter,
        ),
      ),
    );
  }

  @override
  State<ImageFilterPage> createState() => _ImageFilterPageState();
}

class _ImageFilterPageState extends State<ImageFilterPage> {
  late Color _selectedFilter;
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
    Colors.orange.withOpacity(0.3),
    Colors.pink.shade200.withOpacity(0.3),
    Colors.indigo.withOpacity(0.3),
    Colors.lime.withOpacity(0.3),
  ];

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter;
    isGif = widget.image.path.toLowerCase().endsWith('.gif');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151019),  
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white70),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              widget.onFilterSelected(widget.image, _selectedFilter);
              Navigator.of(context).pop();
            },
            child: const Text('Appliquer', style: TextStyle(color: Color(0xFF3498DB))),  
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
            color: const Color(0xFF151019).withOpacity(0.8),  
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
                            ? const Color(0xFFFFFFFF)  
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
      final blockRatio = BlocGrid.getBlockRatio(context);
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: CropAspectRatio(ratioX: blockRatio, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Recadrer l\'image',
            toolbarColor: const Color(0xFF3498DB),  // Couleur modifiée
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
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
        await ImageFilterPage.show(
          context: context,
          image: imageFile,
          onFilterSelected: (image, filter) {
            setState(() {
              images[index] = image;
            });
            onFilterChange(index, filter);
          },
        );
      }
    }
  }
}

Future<void> takePhoto(int index, List<XFile?> images, Function setState,
    BuildContext context, Function(int, Color) onFilterChange) async {
  if (!context.mounted) return;

  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.camera);

  if (pickedFile != null && context.mounted) {
    final blockRatio = BlocGrid.getBlockRatio(context);
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      aspectRatio: CropAspectRatio(ratioX: blockRatio, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Recadrer l\'image',
          toolbarColor: const Color(0xFF151019),  // Couleur demandée
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: true,
          activeControlsWidgetColor: Colors.white,  
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
      await ImageFilterPage.show(
        context: context,
        image: imageFile,
        onFilterSelected: (image, filter) {
          setState(() {
            images[index] = image;
          });
          onFilterChange(index, filter);
        },
      );
    } else {
      print('No photo taken');
    }
  }
}
