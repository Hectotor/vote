import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'help_support_page.dart';
import 'delete_account_dialog.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _darkMode = false;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _darkMode = prefs.getBool('darkMode') ?? false;
        _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      });
    } catch (e) {
      print('Erreur lors du chargement des paramètres: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('darkMode', _darkMode);
      await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    } catch (e) {
      print('Erreur lors de la sauvegarde des paramètres: $e');
    }
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la déconnexion: $e')),
      );
    }
  }

  Future<void> _deleteAccount() async {
    // Afficher une boîte de dialogue de confirmation
    final confirmed = await DeleteAccountDialog.show(context);

    if (!confirmed) return;

    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Supprimer les données utilisateur de Firestore
        await _firestore.collection('users').doc(user.uid).delete();
        
        // Supprimer les posts de l'utilisateur
        final postsSnapshot = await _firestore
            .collection('posts')
            .where('userId', isEqualTo: user.uid)
            .get();
            
        for (var doc in postsSnapshot.docs) {
          await _firestore.collection('posts').doc(doc.id).delete();
        }
        
        // Supprimer le compte Firebase Auth
        await user.delete();
        
        // Rediriger vers la page de connexion
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression du compte: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          // Section Profil
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Modifier le profil'),
            onTap: () {
              Navigator.of(context).pushNamed('/edit-profile');
            },
          ),
          const Divider(),
          
          // Section Paramètres
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
            child: Text('Paramètres', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          SwitchListTile(
            title: const Text('Mode sombre'),
            value: _darkMode,
            onChanged: (value) {
              setState(() {
                _darkMode = value;
                _saveSettings();
              });
            },
          ),
          SwitchListTile(
            title: const Text('Notifications'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
                _saveSettings();
              });
            },
          ),
          const Divider(),
          
          // Section Compte
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
            child: Text('Compte', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Confidentialité'),
            onTap: () {
              // Naviguer vers la page de confidentialité
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Aide et support'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpSupportPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Déconnexion'),
            onTap: _signOut,
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.black),
            title: const Text('Supprimer le compte', style: TextStyle(color: Colors.black)),
            onTap: _deleteAccount,
          ),
        ],
      ),
    );
  }
}
