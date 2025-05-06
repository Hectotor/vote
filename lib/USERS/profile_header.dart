import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileHeader extends StatelessWidget {
  final String userId;

  const ProfileHeader({
    Key? key,
    required this.userId,
  }) : super(key: key);

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
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.blue,
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
                        ),
                        child: userData['photoUrl'] != null
                            ? ClipOval(
                                child: Image.network(
                                  userData['photoUrl'],
                                  fit: BoxFit.cover,
                                  width: 80,
                                  height: 80,
                                ),
                              )
                            : Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.grey[600],
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
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    return doc.data() ?? {};
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
