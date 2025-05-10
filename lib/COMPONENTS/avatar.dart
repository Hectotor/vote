import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Avatar extends StatefulWidget {
  final String userId;
  final double radius;
  final VoidCallback? onTap;

  const Avatar({
    Key? key,
    required this.userId,
    this.radius = 20.0,
    this.onTap,
  }) : super(key: key);

  @override
  State<Avatar> createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _profileImageUrl;
  Color? _filterColor;

  Future<void> _loadUserData() async {
    final doc = await _firestore.collection('users').doc(widget.userId).get();
    final data = doc.data();
    if (data != null) {
      setState(() {
        _profileImageUrl = data['profilePhotoUrl'];
        if (data['filterColor'] != null) {
          _filterColor = Color(data['filterColor']);
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: widget.radius * 2,
        height: widget.radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: ClipOval(
          child: _profileImageUrl != null
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      _profileImageUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: SizedBox(
                            width: widget.radius / 1.5,
                            height: widget.radius / 1.5,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.person, color: Colors.white54),
                    ),
                    if (_filterColor != null)
                      Container(
                        color: _filterColor!.withOpacity(0.3),
                      ),
                  ],
                )
              : const Center(
                  child: Icon(Icons.person, color: Colors.white54),
                ),
        ),
      ),
    );
  }
}
