import 'package:flutter/material.dart';

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
      backgroundColor: Color(0xFF121212),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
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
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildModernTile(
              icon: Icons.image,
              title: 'Choisir une image',
              color: Colors.purple[300]!,
              onTap: onAddPhoto,
            ),
            SizedBox(height: 10),
            _buildModernTile(
              icon: Icons.camera_alt,
              title: 'Prendre une photo',
              color: Colors.green[300]!,
              onTap: onTakePhoto,
            ),
            SizedBox(height: 10),
            if (hasImage) 
              _buildModernTile(
                icon: Icons.text_fields,
                title: 'Ajouter un texte',
                color: Colors.blue[300]!,
                onTap: onAddText,
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
    required VoidCallback? onTap,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
        foregroundColor: Colors.white,
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        side: BorderSide.none,
      ),
      onPressed: onTap,
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
    );
  }
}
