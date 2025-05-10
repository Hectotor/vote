import 'package:flutter/material.dart';
import 'image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class AddOption extends StatelessWidget {
  final Function(XFile, Color)? onAddPhoto;
  final Function(XFile, Color)? onTakePhoto;
  final VoidCallback? onAddText;
  final VoidCallback? onRemoveImage;
  final bool hasImage;
  final bool hasText;

  const AddOption({
    Key? key,
    this.onAddPhoto,
    this.onTakePhoto,
    this.onAddText,
    this.onRemoveImage,
    this.hasImage = false,
    this.hasText = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
            decoration: BoxDecoration(
              color: const Color(0xFF151019),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 1,
                  offset: const Offset(0, 8),
                )
              ],
            ),
      
      padding: EdgeInsets.only(top: 10, left: 24, right: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 150),
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFF2D3748),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Gérer',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 32),
          _buildModernTile(
            title: 'Choisir une image',
            icon: Icons.image_outlined,
            onTap: () => _pickAndProcessImage(context, ImageSource.gallery),
          ),
          SizedBox(height: 24),
          _buildModernTile(
            title: 'Prendre une photo',
            icon: Icons.camera_alt_outlined,
            onTap: () => _pickAndProcessImage(context, ImageSource.camera),
          ),
          if (hasImage)
            Column(
              children: [
                SizedBox(height: 24),
                _buildModernTile(
                  title: 'Supprimer l\'image',
                  icon: Icons.delete_outline,
                  onTap: () {
                    if (onRemoveImage != null) {
                      onRemoveImage!();
                    }
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _pickAndProcessImage(BuildContext context, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Recadrer l\'image',
              toolbarColor: const Color(0xFF151019),
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
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

        if (croppedFile != null) {
          final imageFile = XFile(croppedFile.path);
          
          // Utiliser une méthode statique pour gérer la navigation et le filtre
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImageFilterPage(
                image: imageFile,
                onFilterSelected: (image, filterColor) {
                  if (source == ImageSource.gallery && onAddPhoto != null) {
                    onAddPhoto!(image, filterColor);
                  } else if (source == ImageSource.camera && onTakePhoto != null) {
                    onTakePhoto!(image, filterColor);
                  }
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('Erreur lors de la sélection ou du traitement de l\'image: $e');
    }
  }

  Widget _buildModernTile({
    required String title,
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    final isDelete = title == "Supprimer l'image";
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: isDelete ? const Color(0xFFE53E3E) : const Color(0xFF2D3748),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            SizedBox(width: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
