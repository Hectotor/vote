import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_header.dart';
import 'user_content_view.dart';
import '../models/reusable_login_button.dart';

class UserPage extends StatefulWidget {
  final String? userId;
  final bool showLoginButton;

  const UserPage({
    super.key,
    this.userId,
    this.showLoginButton = true,
  });

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
    _userId = widget.userId;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (_userId != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .get();
      
      // Récupérer toutes les données utilisateur
      final data = doc.data() ?? {};
      
      setState(() {
        _pseudo = data['pseudo'];
        _userData = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Vu00e9rifier si l'utilisateur est authentifiu00e9
    final user = FirebaseAuth.instance.currentUser;
    if (user == null && widget.showLoginButton) {
      // Afficher le bouton de connexion si l'utilisateur n'est pas authentifiu00e9 et que showLoginButton est true
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
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // En-tête du profil avec les données utilisateur déjà chargées et gestion des onglets
            ProfileHeader(
              userId: _userId ?? '',
              userData: _userData ?? {},
              showPosts: _showPosts,
              onTabChanged: (showPosts) {
                setState(() {
                  _showPosts = showPosts;
                });
              },
              isOwner: _userId == FirebaseAuth.instance.currentUser?.uid,
            ),
            
            // Contenu avec IndexedStack pour éviter le rechargement complet
            IndexedStack(
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
          ],
        ),
      ),
    );
  }
}
