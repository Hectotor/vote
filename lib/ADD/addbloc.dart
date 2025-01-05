import 'package:flutter/material.dart';

class AddBloc extends StatelessWidget {
  const AddBloc({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      contentPadding: const EdgeInsets.all(16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Ajouter un bloc',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildOption('Bloc 3', Icons.grid_3x3),
              _buildOption('Bloc 4', Icons.grid_4x4),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), // Annuler
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            // Logique pour ajouter
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A237E),
          ),
          child: const Text(
            'Ajouter',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildOption(String title, IconData icon) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, size: 30),
          onPressed: () {
            // Logique pour ajouter le bloc
          },
        ),
        Text(title),
      ],
    );
  }
}
