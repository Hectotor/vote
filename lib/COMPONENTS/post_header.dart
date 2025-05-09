import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toplyke/COMPONENTS/date_formatter.dart';
import 'package:toplyke/COMPONENTS/report_button.dart';

class PostHeader extends StatelessWidget {
  final String pseudo;
  final Timestamp createdAt;
  final bool isDarkMode;
  final String postId;

  const PostHeader({
    Key? key,
    required this.pseudo,
    required this.createdAt,
    required this.isDarkMode,
    required this.postId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), // ajuster le padding vertical de 10 à 5
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey[300],
            backgroundImage: NetworkImage(
              'https://ui-avatars.com/api/?name=$pseudo&background=random'
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pseudo,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  'Publié ${DateFormatter.formatDate(createdAt)}',
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ReportButton(
            postId: postId,
            isDarkMode: isDarkMode,
          ),
        ],
      ),
    );
  }
}
