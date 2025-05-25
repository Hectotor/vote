import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../INSCRIPTION/connexion_screen.dart';
import 'help_support_page.dart';
import 'setting_profil.dart';
import '../delete_account_dialog.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const ConnexionPage()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la déconnexion: $e')),
      );
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await DeleteAccountDialog.show(context);
    if (!confirmed) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final user = _auth.currentUser;
      if (user != null) {
        final callable = FirebaseFunctions.instance.httpsCallable('deleteUserAccount');
        final result = await callable.call();

        Navigator.of(context).pop();

        if (result.data['success'] == true) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const ConnexionPage()),
            (route) => false,
          );
        } else {
          throw Exception(result.data['message'] ?? 'Erreur inconnue');
        }
      }
    } catch (e) {
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression du compte: $e')),
      );
    }
  }

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget buildMenuItem(IconData icon, String title, VoidCallback onTap,
      {Color iconColor = Colors.black}) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: const TextStyle(fontSize: 16)),
        trailing: const Icon(Icons.arrow_back, size: 16),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 10),
          buildSectionTitle('Profil'),
          buildMenuItem(Icons.person_outline, 'Modifier le profil', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingProfilePage()),
            );
          }),

          buildSectionTitle('Compte'),
          buildMenuItem(Icons.help_outline, 'Aide et support', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HelpSupportPage()),
            );
          }),
          buildMenuItem(Icons.logout, 'Déconnexion', _signOut),
          buildMenuItem(Icons.delete_outline, 'Supprimer le compte', _deleteAccount,
              iconColor: Colors.red),

          const SizedBox(height: 20),
          Center(
            child: Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
