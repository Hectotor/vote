import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../ADD/addoption.dart';

class ProfileHeader extends StatefulWidget {
  final String userId;

  const ProfileHeader({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  String? _profileImageUrl;
  Color? _filterColor;
  bool _isLoading = false;

  Future<void> _uploadProfileImage(XFile image, Color filterColor) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Uploader l'image vers Firebase Storage
      final Reference ref = _storage.ref().child('users/${widget.userId}/profilePhotoUrl');
      await ref.putFile(File(image.path));
      
      // Obtenir l'URL de l'image
      final String downloadUrl = await ref.getDownloadURL();
      
      // Vérifier que l'URL est valide
      if (downloadUrl.isEmpty) {
        throw Exception('URL de téléchargement invalide');
      }
      
      // Mettre à jour l'URL dans Firestore
      await _firestore.collection('users').doc(widget.userId).update({
        'profilePhotoUrl': downloadUrl,
        'filterColor': filterColor.value.toString(),
      });
      
      setState(() {
        _profileImageUrl = downloadUrl;
        _filterColor = filterColor;
      });
    } catch (e) {
      print('Erreur lors de l\'upload de l\'image: $e');
      // Réinitialiser l'URL si l'upload échoue
      setState(() {
        _profileImageUrl = null;
        _filterColor = null;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showAddOptionDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AddOption(
        onAddPhoto: (image, filterColor) {
          // Fermer le popup
          Navigator.of(context).pop();
          // Traiter l'image
          _uploadProfileImage(image, filterColor);
        },
        onTakePhoto: (image, filterColor) {
          // Fermer le popup
          Navigator.of(context).pop();
          // Traiter l'image
          _uploadProfileImage(image, filterColor);
        },
        hasImage: _profileImageUrl != null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return const Center(child: Text('Profil non trouvé'));
        }

        final userData = snapshot.data!;

        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar et Stats
              Row(
                children: [
                  // Avatar
                  GestureDetector(
                    onTap: _showAddOptionDialog,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey[600]!,
                          width: 2,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.transparent,
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (_profileImageUrl != null)
                                Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    // Image
                                    ClipOval(
                                      child: Image.network(
                                        _profileImageUrl!,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress.expectedTotalBytes != null
                                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                  : null,
                                              color: Colors.white,
                                              strokeWidth: 2.0,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    // Filtre
                                    if (_filterColor != null)
                                      Positioned.fill(
                                        child: ClipOval(
                                          child: Container(
                                            color: _filterColor!.withOpacity(0.3),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              if (_isLoading)
                                const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.0,
                                  ),
                                )
                              else if (_profileImageUrl == null)
                                Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.grey[600],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Espacement entre avatar et stats
                  //const SizedBox(width: 30),
                  // Stats
                  Expanded(
                    child: Row(
                      children: [
                        // Espacement avant le premier stat
                        const SizedBox(width: 40),
                        _buildStatColumn(
                          count: userData['posts']?.length ?? 0,
                          label: 'Posts',
                          color: Colors.blue,
                        ),
                        // Espacement entre les stats
                        const SizedBox(width: 40),
                        _buildStatColumn(
                          count: userData['followers']?.length ?? 0,
                          label: 'Followers',
                          color: Colors.purple,
                        ),
                        // Espacement entre les stats
                        const SizedBox(width: 30),
                        _buildStatColumn(
                          count: userData['following']?.length ?? 0,
                          label: 'Following',
                          color: Colors.orange,
                        ),
                        // Espacement après le dernier stat
                        //const SizedBox(width: 25),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _getUserData() async {
    final doc = await _firestore.collection('users').doc(widget.userId).get();
    return doc.data() as Map<String, dynamic>;
  }

  Widget _buildStatColumn({
    required int count,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
