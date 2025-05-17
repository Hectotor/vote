import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toplyke/COMPONENTS/date_formatter.dart';
import 'package:toplyke/COMPONENTS/post_menu.dart';
import 'package:toplyke/COMPONENTS/avatar.dart';
import 'package:toplyke/USERS/user_page.dart';

class PostHeader extends StatelessWidget {
  final String pseudo;
  final String? profilePhotoUrl;
  final int? filterColor;
  final Timestamp createdAt;
  final String postId;
  final String userId;

  const PostHeader({
    Key? key,
    required this.pseudo,
    this.profilePhotoUrl,
    this.filterColor,
    required this.createdAt,
    required this.postId,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 4, right: 4),
      child: Row(
        children: [
          Avatar(
            userId: userId,
            radius: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserPage(
                          userId: userId,
                          showLoginButton: false,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    pseudo,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  'Publié ${DateFormatter.formatDate(createdAt)}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          PostMenu(
            postId: postId,
            userId: userId,
          ),
        ],
      ),
    );
  }
}
