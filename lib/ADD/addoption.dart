import 'package:flutter/material.dart';
import 'image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'bloc.dart';

class AddOption extends StatelessWidget {
  final VoidCallback? onAddPhoto;
  final VoidCallback? onTakePhoto;
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
      insetPadding: EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF151019),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 30,
              offset: Offset(0, 15),
            )
          ],
        ),
        padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            SizedBox(height: 16),
            if (hasImage) 
              _buildModernTile(
                title: 'Ajouter un texte',
                icon: Icons.text_fields_outlined,
                onTap: onAddText,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndProcessImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      // Utiliser un ratio fixe basé sur 200.0
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1), // Carré pour correspondre à 200.0
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
        
        // Fermer le dialogue actuel
        Navigator.of(context).pop();

        // Naviguer vers la page de filtres
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ImageFilterPage(
              image: imageFile,
              onFilterSelected: (XFile image, Color filterColor) {
                // Appeler le callback approprié
                if (source == ImageSource.gallery && onAddPhoto != null) {
                  onAddPhoto!();
                } else if (source == ImageSource.camera && onTakePhoto != null) {
                  onTakePhoto!();
                }
              },
            ),
          ),
        );
      }
    }
  }

  Widget _buildModernTile({
    required String title,
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
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
                      color: Colors.white.withOpacity(1),
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white.withOpacity(1),
                        fontSize: 16,
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
