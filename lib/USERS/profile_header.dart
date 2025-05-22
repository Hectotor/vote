
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../COMPONENTS/avatar.dart';
import '../ADD/addoption.dart';
import 'follow_service.dart';
import 'followers_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileHeader extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> userData;
  final bool isOwner;

  const ProfileHeader({
    Key? key,
    required this.userId,
    required this.userData,
    required this.isOwner,
  }) : super(key: key);

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FollowService _followService = FollowService();
  String? _profileImageUrl;
  bool _isLoading = false;
  final TextEditingController _bioController = TextEditingController();

  int _followersCount = 0;
  int _followingCount = 0;

  Future<void> _checkFollowingStatus() async {
    if (_auth.currentUser == null) return;
    await _followService.isFollowing(widget.userId);
    setState(() {
      _followersCount = widget.userData['followers']?.length ?? 0;
      _followingCount = widget.userData['following']?.length ?? 0;
    });
  }

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
    _checkFollowingStatus();
    if (widget.userData['bio'] != null) {
      _bioController.text = widget.userData['bio'];
    }
    _profileImageUrl = widget.userData['profilePhotoUrl'];
  }
  


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          padding: const EdgeInsets.all (0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white,
              width: 5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Stack(
                    children: [
                      _isLoading
                        ? const CircularProgressIndicator()
                        : Avatar(
                            userId: widget.userId,
                            radius: 35,
                            onTap: widget.isOwner ? _showAddOptionBottomSheet : null,
                          ),
                      if (widget.isOwner && !_isLoading)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.add_a_photo,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatColumn(
                          count: widget.userData['publishpostscount'] ?? 0,
                          label: 'Posts',
                          onTap: null,
                        ),
                        _buildStatColumn(
                          count: widget.userData['votesCountUser'] ?? 0,
                          label: 'Votes',
                          onTap: null,
                        ),
                        _buildStatColumn(
                          count: _followersCount,
                          label: 'Followers',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FollowersPage(
                                  userId: widget.userId,
                                  type: 'followers',
                                  title: 'Followers',
                                ),
                              ),
                            );
                          },
                        ),
                        _buildStatColumn(
                          count: _followingCount,
                          label: 'Following',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FollowersPage(
                                  userId: widget.userId,
                                  type: 'following',
                                  title: 'Following',
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),  
              const SizedBox(height: 25),
            ],
          ),
        ),

      ],
    );
  }

  Widget _buildStatColumn({
    required int count,
    required String label,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF757575),
            ),
          ),
        ],
      ),
    );
  }
}
