import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toplyke/COMPONENTS/date_formatter.dart';
import 'package:toplyke/COMPONENTS/post_menu.dart';

class PostHeader extends StatelessWidget {
  final String pseudo;
  final String? profilePhotoUrl;
  final Color? filterColor;
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: profilePhotoUrl != null
                ? NetworkImage(profilePhotoUrl!)
                : NetworkImage(
                    'https://ui-avatars.com/api/?name=$pseudo&background=random'
                  ),
            child: filterColor != null
                ? Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: filterColor!.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(18),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pseudo,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
