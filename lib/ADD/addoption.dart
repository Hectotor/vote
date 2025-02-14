import 'package:flutter/material.dart';

class AddOption extends StatelessWidget {
  final VoidCallback onAddText;
  final VoidCallback onAddPhoto;
  final VoidCallback onTakePhoto;
  final VoidCallback? onDeleteContent;
  final bool hasImage;
  final bool hasText;

  const AddOption({
    super.key,
    required this.onAddText,
    required this.onAddPhoto,
    required this.onTakePhoto,
    this.onDeleteContent,
    this.hasImage = false,
    this.hasText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: Color(0xFF121212),
      elevation: 8,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF121212),
              Color(0xFF0A0A0A),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        constraints: BoxConstraints(maxWidth: 300),
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!hasText)
              _buildModernTile(
                icon: Icons.edit,
                title: 'Ajouter du texte',
                color: Colors.blue[300]!,
                onTap: onAddText,
              ),
            _buildModernTile(
              icon: Icons.image,
              title: 'Choisir une image',
              color: Colors.purple[300]!,
              onTap: onAddPhoto,
            ),
            _buildModernTile(
              icon: Icons.camera_alt,
              title: 'Prendre une photo',
              color: Colors.green[300]!,
              onTap: onTakePhoto,
            ),
            if (hasImage && onDeleteContent != null)
              _buildModernTile(
                icon: Icons.delete,
                title: 'Supprimer',
                color: Colors.red[300]!,
                onTap: () => onDeleteContent!(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[500]),
          ],
        ),
      ),
    );
  }
}
