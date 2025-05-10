import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Avatar extends StatefulWidget {
  final String userId;
  final double radius;
  final VoidCallback? onTap;

  const Avatar({
    Key? key,
    required this.userId,
    this.radius = 18.0,
    this.onTap,
  }) : super(key: key);

  @override
  State<Avatar> createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _profileImageUrl;
  Color? _filterColor;
  bool _isLoading = false;

  Future<Map<String, dynamic>> _getUserData() async {
    final doc = await _firestore.collection('users').doc(widget.userId).get();
    final userData = doc.data();
    
    if (userData != null) {
      _profileImageUrl = userData['profilePhotoUrl'];
      if (userData['filterColor'] != null) {
        _filterColor = Color(userData['filterColor']);
      }
    }
    
    return userData ?? {};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2.0,
          );
        }

        return GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: widget.radius * 2,
            height: widget.radius * 2,
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
                width: double.infinity,
                height: double.infinity,
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
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
