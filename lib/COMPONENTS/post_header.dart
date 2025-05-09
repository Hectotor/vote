import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toplyke/COMPONENTS/date_formatter.dart';

class PostHeader extends StatelessWidget {
  final String pseudo;
  final Timestamp createdAt;
  final bool isDarkMode;
  final VoidCallback? onMorePressed;

  const PostHeader({
    Key? key,
    required this.pseudo,
    required this.createdAt,
    required this.isDarkMode,
    this.onMorePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: onMorePressed,
          ),
        ],
      ),
    );
  }
}
