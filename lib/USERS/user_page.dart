import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_header.dart';
import 'user_content_view.dart';
import '../models/reusable_login_button.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  String? _userId;
  String? _pseudo;
  Map<String, dynamic>? _userData;
  bool _showPosts = true; // true pour Posts, false pour Sauvegardés

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      // Récupérer toutes les données utilisateur en une seule fois
      final data = doc.data() ?? {};
      
      setState(() {
        _userId = user.uid;
        _pseudo = data['pseudo'];
        _userData = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Vu00e9rifier si l'utilisateur est authentifiu00e9
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Afficher le bouton de connexion si l'utilisateur n'est pas authentifiu00e9
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profil'),
        ),
        body: const Center(
          child: ReusableLoginButton(),
        ),
      );
    }
    
    // Afficher un indicateur de chargement pendant le chargement des donnu00e9es
    if (_userId == null || _userData == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            _pseudo ?? 'Utilisateur',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Action de recherche
            },
          ),
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              // Action du menu
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // En-tête du profil avec les données utilisateur déjà chargées
          ProfileHeader(
            userId: _userId!,
            userData: _userData!,
          ),
          
          // Bannière de navigation
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF151019),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Bouton Posts
                  _buildNavButton(
                    label: 'Posts',
                    icon: Icons.grid_on,
                    isSelected: _showPosts,
                    onTap: () {
                      setState(() {
                        _showPosts = true;
                      });
                    },
                  ),
                  
                  // Bouton Sauvegardés
                  _buildNavButton(
                    label: 'Sauvegardés',
                    icon: Icons.bookmark,
                    isSelected: !_showPosts,
                    onTap: () {
                      setState(() {
                        _showPosts = false;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // Contenu avec IndexedStack pour u00e9viter le rechargement complet
          Expanded(
            child: IndexedStack(
              index: _showPosts ? 0 : 1,
              children: [
                // Page des posts de l'utilisateur (index 0)
                Container(
                  color: Colors.black,
                  child: UserContentView(
                    userId: _userId!,
                    showPosts: true,
                  ),
                ),
                // Page des posts sauvegardés (index 1)
                Container(
                  color: Colors.black,
                  child: UserContentView(
                    userId: _userId!,
                    showPosts: false,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  
  // Méthode helper pour construire les boutons de navigation
  Widget _buildNavButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.blue : Colors.grey,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            height: 2,
            width: 40,
            color: isSelected ? Colors.blue : Colors.transparent,
          ),
        ],
      ),
    );
  }
}
