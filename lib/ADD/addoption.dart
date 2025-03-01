import 'package:flutter/material.dart';
import 'image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class AddOption extends StatelessWidget {
  final Function(XFile, Color)? onAddPhoto;
  final Function(XFile, Color)? onTakePhoto;
  final VoidCallback? onAddText;
  final bool hasImage;
  final bool hasText;

  const AddOption({
    Key? key,
    this.onAddPhoto,
    this.onTakePhoto,
    this.onAddText,
    this.hasImage = false,
    this.hasText = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Bords arrondis
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color(0xFF151019), // Nouvelle couleur de fond
          borderRadius: BorderRadius.circular(16), // Bords arrondis
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 1,
              offset: Offset(0, 8),
            )
          ],
        ),
        padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Ajouter une option',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 24),
            _buildModernTile(
              title: 'Choisir une image',
              icon: Icons.image_outlined,
              onTap: () => _pickAndProcessImage(context, ImageSource.gallery),
            ),
            SizedBox(height: 16),
            _buildModernTile(
              title: 'Prendre une photo',
              icon: Icons.camera_alt_outlined,
              onTap: () => _pickAndProcessImage(context, ImageSource.camera),
            ),
          ],
        ),
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
          await ImageFilterPage.show(
            context: context, 
            image: imageFile, 
            onFilterSelected: (image, filterColor) {
              if (source == ImageSource.gallery && onAddPhoto != null) {
                onAddPhoto!(image, filterColor);
              } else if (source == ImageSource.camera && onTakePhoto != null) {
                onTakePhoto!(image, filterColor);
              }
            },
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10), // Bords arrondis pour les tuiles
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10), // Correspondance avec le container
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      color: Colors.white,
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.white.withOpacity(0.7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
