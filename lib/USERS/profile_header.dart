
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../COMPONENTS/avatar.dart';
import '../ADD/addoption.dart';

class ProfileHeader extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> userData;
  final bool showPosts;
  final Function(bool)? onTabChanged;
  final bool isOwner;

  const ProfileHeader({
    Key? key,
    required this.userId,
    required this.userData,
    this.showPosts = true,
    this.onTabChanged,
    required this.isOwner,
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
  bool _showPosts = true;

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
            final Reference ref = _storage.ref().child('users/${widget.userId}/profilePhotoUrl');
            await ref.delete();
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
    setState(() => _isLoading = true);
    try {
      final Reference ref = _storage.ref().child('users/${widget.userId}/profilePhotoUrl');
      await ref.putFile(File(image.path));
      final String downloadUrl = await ref.getDownloadURL();
      if (downloadUrl.isEmpty) throw Exception('URL de téléchargement invalide');
      await _firestore.collection('users').doc(widget.userId).update({
        'profilePhotoUrl': downloadUrl,
        'filterColor': filterColor.value,
      });
      setState(() => _profileImageUrl = downloadUrl);
    } catch (e) {
      print('Erreur lors de l\'upload de l\'image: $e');
      setState(() => _profileImageUrl = null);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.userData['bio'] != null) {
      _bioController.text = widget.userData['bio'];
    }
    _profileImageUrl = widget.userData['profilePhotoUrl'];
    _showPosts = widget.showPosts;
  }

  Widget _buildTabButton({required String label, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        alignment: Alignment.center,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2C),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _isLoading
                      ? const CircularProgressIndicator()
                      : Avatar(
                          userId: widget.userId,
                          radius: 35,
                          onTap: _showAddOptionBottomSheet,
                        ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatColumn(count: widget.userData['posts']?.length ?? 0, label: 'Posts', color: Colors.blue),
                        _buildStatColumn(count: widget.userData['followers']?.length ?? 0, label: 'Followers', color: Colors.purple),
                        _buildStatColumn(count: widget.userData['following']?.length ?? 0, label: 'Following', color: Colors.orange),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                ],
              ),
              if (widget.isOwner)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: _buildTabButton(
                          label: 'Posts',
                          isSelected: _showPosts,
                          onTap: () {
                            setState(() => _showPosts = true);
                            widget.onTabChanged?.call(true);
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: _buildTabButton(
                          label: 'Sauvegardés',
                          isSelected: !_showPosts,
                          onTap: () {
                            setState(() => _showPosts = false);
                            widget.onTabChanged?.call(false);
                          },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

      ],
    );
  }

  Widget _buildStatColumn({required int count, required String label, required Color color}) {
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
        const SizedBox(height: 4),
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
