import 'package:flutter/material.dart';
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
      height: 300,
      padding: EdgeInsets.only(
        top: 10, 
        left: 24, 
        right: 24,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF000000),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.4), // 0.4 opacity
            blurRadius: 30,
            spreadRadius: 0.5,
            offset: const Offset(0, 10), // ombre légère vers le bas
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Barre de glissement supprimée pour correspondre au design de CustomDateRoller
          SizedBox(height: 16),
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
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (image != null) {
        // D'abord recadrer l'image
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: image.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Recadrer l\'image',
              toolbarColor: const Color(0xFF3498DB),
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

        if (croppedFile != null) {
          final imageFile = XFile(croppedFile.path);
          
          // Appeler directement le callback approprié avec l'image recadrée
          // Le filtre sera appliqué dans le widget parent
          if (source == ImageSource.gallery && onAddPhoto != null) {
            onAddPhoto!(imageFile, Colors.transparent);
          } else if (source == ImageSource.camera && onTakePhoto != null) {
            onTakePhoto!(imageFile, Colors.transparent);
          }
        }
      }
    } catch (e) {
      print('Erreur lors de la sélection ou du traitement de l\'image: $e');
      // Afficher un message d'erreur à l'utilisateur
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors du traitement de l\'image')),
        );
      }
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
