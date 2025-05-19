import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_header.dart';
import 'user_content_view.dart';
import '../models/reusable_login_button.dart';

import 'follow_service.dart';

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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FollowService _followService = FollowService();
  String? _userId;
  String? _pseudo;
  Map<String, dynamic>? _userData;
  bool _showPosts = true; // true pour Posts, false pour Sauvegardés
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _userId = widget.userId ?? _auth.currentUser?.uid;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (_userId != null) {
      final doc = await _firestore.collection('users').doc(_userId).get();
      
      // Récupérer toutes les données utilisateur
      final data = doc.data() ?? {};
      
      setState(() {
        _userData = data;
        _pseudo = data['pseudo'];
      });
      
      // Vérifier l'état de suivi après avoir chargé les données utilisateur
      await _checkFollowingStatus();
    }
  }

  Future<void> _checkFollowingStatus() async {
    if (_auth.currentUser == null || _userId == null || _userId == _auth.currentUser?.uid) {
      setState(() {
        _isFollowing = false;
      });
      return;
    }
    
    final isFollowing = await _followService.isFollowing(_userId!);
    setState(() {
      _isFollowing = isFollowing;
    });
  }

  Future<void> _toggleFollow() async {
    if (_auth.currentUser == null || _userId == null) return;
    if (_isFollowing) {
      await _followService.unfollowUser(_userId!);
    } else {
      await _followService.followUser(_userId!);
    }
    setState(() {
      _isFollowing = !_isFollowing;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Vérifier si l'utilisateur est authentifié
    final user = FirebaseAuth.instance.currentUser;
    if (user == null && widget.showLoginButton) {
      // Afficher le bouton de connexion si l'utilisateur n'est pas authentifié et que showLoginButton est true
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profil'),
        ),
        body: const Center(
          child: ReusableLoginButton(),
        ),
      );
    }
    
    // Afficher un indicateur de chargement pendant le chargement des données
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
            if (_userId != _auth.currentUser?.uid) ...[
              IconButton(
                icon: Icon(
                  _isFollowing ? Icons.person_remove : Icons.person_add,
                  color: _isFollowing ? Colors.grey : Colors.blue,
                ),
                onPressed: _toggleFollow,
              ),
            ],
            if (_userId == _auth.currentUser?.uid) ...[
              IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  // Action du menu
                },
              ),
            ],
            const SizedBox(width: 16),
          ],
        ),
        body: IndexedStack(
          index: _showPosts ? 0 : 1,
          children: [
            // Page des posts de l'utilisateur (index 0)
            Container(
              color: Colors.transparent,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // En-tête du profil avec les données utilisateur déjà chargées et gestion des onglets
                    ProfileHeader(
                      userId: _userId ?? '',
                      userData: _userData ?? {},
                      showPosts: true,
                      onTabChanged: (showPosts) {
                        setState(() {
                          _showPosts = showPosts;
                        });
                      },
                      isOwner: _userId == FirebaseAuth.instance.currentUser?.uid,
                    ),
                    
                    // Contenu des posts
                    Container(
                      constraints: BoxConstraints(
                        // Définir une hauteur minimale pour permettre le défilement même avec peu de contenu
                        minHeight: MediaQuery.of(context).size.height - 200,
                      ),
                      child: UserContentView(
                        userId: _userId!,
                        showPosts: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Page des posts sauvegardés (index 1)
            Container(
              color: Colors.transparent,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // En-tête du profil avec les données utilisateur déjà chargées et gestion des onglets
                    ProfileHeader(
                      userId: _userId ?? '',
                      userData: _userData ?? {},
                      showPosts: false,
                      onTabChanged: (showPosts) {
                        setState(() {
                          _showPosts = showPosts;
                        });
                      },
                      isOwner: _userId == FirebaseAuth.instance.currentUser?.uid,
                    ),
                    
                    // Contenu des posts sauvegardés
                    Container(
                      constraints: BoxConstraints(
                        // Définir une hauteur minimale pour permettre le défilement même avec peu de contenu
                        minHeight: MediaQuery.of(context).size.height - 200,
                      ),
                      child: UserContentView(
                        userId: _userId!,
                        showPosts: false,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
    );
  }
}
