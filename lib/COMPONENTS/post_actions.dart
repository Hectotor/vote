import 'package:flutter/material.dart';
import 'package:toplyke/HOME/post_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Post/post_like_service.dart';
import 'ANIMATION/heart_animation_post_action.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostActions extends StatefulWidget {
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
  State<PostActions> createState() => _PostActionsState();
}

class _PostActionsState extends State<PostActions> {
  bool _likeLoading = false;
  bool _lastIsLiked = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Méthodes de sauvegarde supprimées car déplacées vers post_menu.dart

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4, bottom: 10),
      child: Row(
        children: [
          // StreamBuilder pour le like
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('posts')
                .doc(widget.postId)
                .snapshots(),
            builder: (context, postSnapshot) {
              final postData = postSnapshot.data?.data() as Map<String, dynamic>?;
              final likeCount = postData?['likesCount'] ?? 0;
              final user = FirebaseAuth.instance.currentUser;
              return StreamBuilder<QuerySnapshot>(
                stream: user != null ? FirebaseFirestore.instance
                    .collection('likes')
                    .where('postId', isEqualTo: widget.postId)
                    .where('userId', isEqualTo: user.uid)
                    .limit(1)
                    .snapshots() : null,
                builder: (context, likeSnapshot) {
                  // Si l'utilisateur n'est pas authentifié, on considère que le post n'est pas liké
                  final isLiked = user != null ? (likeSnapshot.data?.docs.isNotEmpty ?? false) : false;
                  return Row(
                    children: [
                      HeartAnimationPostAction(
                        animate: _likeLoading || (isLiked != _lastIsLiked),
                        isLiked: isLiked,
                        onTap: _likeLoading
                            ? null
                            : () async {
                                setState(() {
                                  _likeLoading = true;
                                  _lastIsLiked = isLiked;
                                });
                                await PostLikeService.likeWithAuthCheck(context, widget.postId);
                                setState(() {
                                  _likeLoading = false;
                                  _lastIsLiked = !isLiked; // pour bien relancer l'anim si besoin
                                });
                              },
                        size: 28,
                      ),
                      Text(
                        '$likeCount',
                        style: TextStyle(
                          //color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          //const SizedBox(width: 10),
          StreamBuilder<DocumentSnapshot>(
            stream: _firestore.collection('posts').doc(widget.postId).snapshots(),
            builder: (context, snapshot) {
              final commentCount = (snapshot.data?.data() as Map<String, dynamic>?)?['commentCount'] ?? 0;
              return Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.chat_bubble_outline,
                      //color: Colors.white,
                      size: 24,
                    ),
                    onPressed: widget.isCommentPage
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation1, animation2) => PostPage(
                                  postId: widget.postId,
                                ),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                          },
                  ),
                  if (snapshot.hasData) Text(
                    '$commentCount',
                    style: TextStyle(
                      //color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.send_outlined,
              //color: Colors.white,
              size: 24,
            ),
            onPressed: () {
              // TODO: Implement share functionality
            },
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
