import 'package:flutter/material.dart';
import 'package:toplyke/PAGES/post_page.dart';

class PostActions extends StatelessWidget {
  final String postId;
  final String userId;
  final bool isCommentPage;

  const PostActions({
    Key? key,
    required this.postId,
    required this.userId,
    this.isCommentPage = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8, top: 4),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.favorite_border,
              color: Colors.white,
              size: 28,
            ),
            onPressed: () {
              // TODO: Implement like functionality
            },
          ),
          IconButton(
            icon: Icon(
              Icons.chat_bubble_outline,
              color: Colors.white,
              size: 24,
            ),
            onPressed: isCommentPage
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostPage(
                          postId: postId,
                        ),
                      ),
                    );
                  },
          ),
          IconButton(
            icon: Icon(
              Icons.send_outlined,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () {
              // TODO: Implement share functionality
            },
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              Icons.bookmark_border,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () {
              // TODO: Implement save functionality
            },
          ),
        ],
      ),
    );
  }
}
