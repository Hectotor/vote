import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../COMPONENTS/avatar.dart';
import 'bio_field.dart';
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
  final TextEditingController _bioController = TextEditingController();

  Future<void> _showAddOptionDialog() async {
    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) => AddOption(
        onAddPhoto: (image, filterColor) {
          if (!mounted) return;
          Navigator.of(context).pop();
          _uploadProfileImage(image, filterColor);
        },
        onTakePhoto: (image, filterColor) {
          if (!mounted) return;
          Navigator.of(context).pop();
          _uploadProfileImage(image, filterColor);
        },
        hasImage: _profileImageUrl != null,
      ),
    );
  }

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
      
      // Mettre à jour l'URL et le filtre dans Firestore
      await _firestore.collection('users').doc(widget.userId).update({
        'profilePhotoUrl': downloadUrl,
        'filterColor': filterColor.value,
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

  Future<Map<String, dynamic>> _getUserData() async {
    final doc = await _firestore.collection('users').doc(widget.userId).get();
    final userData = doc.data() as Map<String, dynamic>;
    
    // Initialiser le contrôleur de bio avec la valeur existante
    if (userData['bio'] != null) {
      _bioController.text = userData['bio'];
    }
    
    return userData;
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
        _profileImageUrl = userData['profilePhotoUrl'];
        if (userData['filterColor'] != null) {
          _filterColor = Color(userData['filterColor']);
        }

        return Container(
          padding: const EdgeInsets.only(top: 0, bottom: 0, left: 16, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Container principal (sans bio)
              Container(
                padding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D3748),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey[800]!,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Avatar
                    Avatar(
                      userId: widget.userId,
                      radius: 35,
                      onTap: _showAddOptionDialog,
                    ),
                    const SizedBox(width: 20),
                    // Stats
                    Expanded(
                      child: Row(
                        children: [
                          // Espacement avant le premier stat
                          const SizedBox(width: 16),
                          _buildStatColumn(
                            count: userData['posts']?.length ?? 0,
                            label: 'Posts',
                            color: Colors.blue,
                          ),
                          // Espacement entre les stats
                          const SizedBox(width: 32),
                          _buildStatColumn(
                            count: userData['followers']?.length ?? 0,
                            label: 'Followers',
                            color: Colors.purple,
                          ),
                          // Espacement entre les stats
                          const SizedBox(width: 32),
                          _buildStatColumn(
                            count: userData['following']?.length ?? 0,
                            label: 'Following',
                            color: Colors.orange,
                          ),
                          // Espacement après le dernier stat
                          //const SizedBox(width: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              //const SizedBox(height: 16),
              // Bio en dehors du container
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                child: BioField(
                  userData: userData,
                  controller: _bioController,
                ),
              ),
            ],
          ),
        );
      },
    );
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
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }
}
