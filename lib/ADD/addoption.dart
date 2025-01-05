import 'package:flutter/material.dart';

class AddOption extends StatelessWidget {
  final VoidCallback onAddText;
  final VoidCallback onAddPhoto;
  final VoidCallback onTakePhoto;
  final VoidCallback? onDeleteContent;

  const AddOption({
    super.key,
    required this.onAddText,
    required this.onAddPhoto,
    required this.onTakePhoto,
    this.onDeleteContent,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.white, // Set background color to white
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Choisir une action",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF08004D),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.text_fields, color: Color(0xFF08004D)),
              title: const Text('Ajouter un texte'),
              onTap: onAddText,
            ),
            ListTile(
              leading:
                  const Icon(Icons.photo_library, color: Color(0xFF08004D)),
              title: const Text('Choisir une image'),
              onTap: onAddPhoto,
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera, color: Color(0xFF08004D)),
              title: const Text('Prendre une photo'),
              onTap: onTakePhoto,
            ),
            if (onDeleteContent != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.redAccent),
                title: const Text('Supprimer le contenu'),
                onTap: onDeleteContent,
              ),
          ],
        ),
      ),
    );
  }
}
