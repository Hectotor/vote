import 'package:flutter/material.dart';

class AddOption extends StatelessWidget {
  final VoidCallback onAddText;
  final VoidCallback onAddPhoto;
  final VoidCallback onTakePhoto;
  final VoidCallback? onDeleteContent;
  final bool hasImage;
  final bool hasText; // Nouveau paramètre

  const AddOption({
    super.key,
    required this.onAddText,
    required this.onAddPhoto,
    required this.onTakePhoto,
    this.onDeleteContent,
    this.hasImage = false,
    this.hasText = false, // Nouvelle option
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.transparent, // Laisse le dégradé visible
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF000000), // Dégradé sombre
              Color(0xFF1D1D2C), // Dégradé bleu
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Choisir une action",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            if (!hasText) // Condition pour afficher le bouton uniquement s'il n'y a pas de texte
              _buildOption(
                icon: Icons.text_fields,
                color: Colors.white,
                title: "Ajouter un texte",
                onTap: onAddText,
              ),
            _buildOption(
              icon: Icons.photo_library,
              color: Colors.white,
              title: "Ajouter une image",
              onTap: onAddPhoto,
            ),
            _buildOption(
              icon: Icons.photo_camera,
              color: Colors.white,
              title: "Prendre une photo",
              onTap: onTakePhoto,
            ),
            if (hasImage && onDeleteContent != null)
              _buildOption(
                icon: Icons.delete,
                color: Colors.redAccent,
                title: "Supprimer l'image",
                onTap: onDeleteContent!,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white, // Texte en blanc
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
        ],
      ),
      onTap: onTap,
    );
  }
}
