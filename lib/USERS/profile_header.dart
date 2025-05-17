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
  final Map<String, dynamic> userData;
  final bool showPosts;
  final Function(bool)? onTabChanged;

  const ProfileHeader({
    Key? key,
    required this.userId,
    required this.userData,
    this.showPosts = true,
    this.onTabChanged,
  }) : super(key: key);

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  String? _profileImageUrl;
  bool _isLoading = false;
  final TextEditingController _bioController = TextEditingController();
  bool _showPosts = true; // true pour Posts, false pour Sauvegardés

  Future<void> _showAddOptionBottomSheet() async {
    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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
        onRemoveImage: () async {
          if (!mounted) return;
          
          try {
            // Supprimer l'image de Firebase Storage
            final Reference ref = _storage.ref().child('users/${widget.userId}/profilePhotoUrl');
            await ref.delete();
            
            // Mettre à jour Firestore
            await _firestore.collection('users').doc(widget.userId).update({
              'profilePhotoUrl': null,
              'filterColor': null,
            });
            
            setState(() {
              _profileImageUrl = null;
            });
          } catch (e) {
            print('Erreur lors de la suppression de l\'image: $e');
          }
        },
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
      });
    } catch (e) {
      print('Erreur lors de l\'upload de l\'image: $e');
      // Réinitialiser l'URL si l'upload échoue
      setState(() {
        _profileImageUrl = null;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialiser le contrôleur de bio avec la valeur existante
    if (widget.userData['bio'] != null) {
      _bioController.text = widget.userData['bio'];
    }
    // Initialiser l'URL de l'image de profil
    _profileImageUrl = widget.userData['profilePhotoUrl'];
    // Initialiser l'état des onglets
    _showPosts = widget.showPosts;
  }

  Widget _buildTabButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[800] : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue[800]! : Colors.grey[800]!,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[300],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                 child: Column(
                   children: [
                     Row(
                       children: [
                         // Avatar
                         _isLoading
                             ? const Center(child: CircularProgressIndicator())
                             : Avatar(
                                 userId: widget.userId,
                                 radius: 35,
                                 onTap: _showAddOptionBottomSheet,
                               ),
                         const SizedBox(width: 20),
                         // Stats
                         Expanded(
                           child: Row(
                             children: [
                               // Espacement avant le premier stat
                               const SizedBox(width: 16),
                               _buildStatColumn(
                                 count: widget.userData['posts']?.length ?? 0,
                                 label: 'Posts',
                                 color: Colors.blue,
                               ),
                               // Espacement entre les stats
                               const SizedBox(width: 32),
                               _buildStatColumn(
                                 count: widget.userData['followers']?.length ?? 0,
                                 label: 'Followers',
                                 color: Colors.purple,
                               ),
                               // Espacement entre les stats
                               const SizedBox(width: 32),
                               _buildStatColumn(
                                 count: widget.userData['following']?.length ?? 0,
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
                     const SizedBox(height: 16),
                     // Boutons Posts et Sauvegardés
                     Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         _buildTabButton(
                           label: 'Posts',
                           isSelected: _showPosts,
                           onTap: () {
                             setState(() {
                               _showPosts = true;
                             });
                             // Notifier le parent du changement
                             if (widget.onTabChanged != null) {
                               widget.onTabChanged!(true);
                             }
                           },
                         ),
                         const SizedBox(width: 16),
                         _buildTabButton(
                           label: 'Sauvegardés',
                           isSelected: !_showPosts,
                           onTap: () {
                             setState(() {
                               _showPosts = false;
                             });
                             // Notifier le parent du changement
                             if (widget.onTabChanged != null) {
                               widget.onTabChanged!(false);
                             }
                           },
                         ),
                       ],
                     ),
                   ],
                 ),
               ),
               //const SizedBox(height: 16),
               // Bio en dehors du container
               Container(
                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                 child: BioField(
                   userData: widget.userData,
                   controller: _bioController,
                 ),
               ),
               const SizedBox(height: 20),
               // Contenu (Posts ou Sauvegardés)
               // Nous n'utilisons pas Expanded ici car ProfileHeader est probablement dans un ScrollView
               // Nous allons plutôt notifier le parent du changement via un callback
            ],
          ),
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
