import 'package:flutter/material.dart';
import 'image.dart';
import 'package:image_picker/image_picker.dart';

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
              onTap: () async {
                final ImagePicker picker = ImagePicker();
                final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ImageFilterPage(
                        image: image,
                        onFilterSelected: (selectedImage, selectedFilter) {
                          // You might want to pass this back to the caller
                          if (onAddPhoto != null) {
                            onAddPhoto!();
                          }
                        },
                      ),
                    ),
                  );
                }
              },
            ),
            SizedBox(height: 16),
            _buildModernTile(
                title: 'Prendre une photo',
                icon: Icons.camera_alt_outlined,
                onTap: () async {
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ImageFilterPage(
                          image: image,
                          onFilterSelected: (selectedImage, selectedFilter) {
                            // Appel de la fonction de callback si définie
                            if (onTakePhoto != null) {
                              onTakePhoto!();
                            }
                          },
                        ),
                      ),
                    );
                  }
                },
          
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
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white.withOpacity(0.5),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
