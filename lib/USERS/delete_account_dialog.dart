import 'package:flutter/material.dart';

class DeleteAccountDialog extends StatelessWidget {
  const DeleteAccountDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Supprimer le compte'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Êtes-vous sûr de vouloir supprimer votre compte ?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text('Toutes les données associées à votre compte seront supprimées définitivement :'),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• Vos publications et sondages'),
                Text('• Vos votes et commentaires'),
                Text('• Votre profil et vos abonnements'),
                Text('• Vos paramètres personnalisés'),
              ],
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Cette action est irréversible et ne peut pas être annulée.',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  /// Affiche le dialogue de confirmation de suppression de compte
  /// Retourne true si l'utilisateur confirme la suppression, false sinon
  static Future<bool> show(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => const DeleteAccountDialog(),
    ) ?? false;
  }
}
