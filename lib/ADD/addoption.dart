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
      height: 240,
      padding: EdgeInsets.only(
        top: 14,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1B202A),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.4),
            blurRadius: 30,
            spreadRadius: 0.5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _buildModernTile(
              title: 'Choisir une image',
              icon: Icons.image_outlined,
              onTap: () => _pickAndProcessImage(context, ImageSource.gallery),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _buildModernTile(
              title: 'Prendre une photo',
              icon: Icons.camera_alt_outlined,
              onTap: () => _pickAndProcessImage(context, ImageSource.camera),
            ),
          ),
          if (hasImage) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildModernTile(
                title: 'Supprimer l\'image',
                icon: Icons.delete_outline,
                onTap: () {
                  if (onRemoveImage != null) {
                    onRemoveImage!();
                  }
                  // Ne pas fermer la page automatiquement
                },
              ),
            ),
          ],
          const SizedBox(height: 8),
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
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
