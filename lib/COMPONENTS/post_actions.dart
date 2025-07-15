import 'package:flutter/material.dart';
import 'package:toplyke/HOME/post_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'Post/post_like_service.dart';
import 'ANIMATION/heart_animation_post_action.dart';

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

  Widget _buildLikeButton() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('posts').doc(widget.postId).snapshots(),
      builder: (context, postSnapshot) {
        final postData = postSnapshot.data?.data() as Map<String, dynamic>?;
        final likeCount = postData?['likesCount'] ?? 0;
        final user = FirebaseAuth.instance.currentUser;

        return StreamBuilder<QuerySnapshot>(
          stream: user != null
              ? _firestore
                  .collection('likes')
                  .where('postId', isEqualTo: widget.postId)
                  .where('userId', isEqualTo: user.uid)
                  .limit(1)
                  .snapshots()
              : null,
          builder: (context, likeSnapshot) {
            final isLiked = user != null
                ? (likeSnapshot.data?.docs.isNotEmpty ?? false)
                : false;

            return InkWell(
              onTap: _likeLoading
                  ? null
                  : () async {
                      setState(() {
                        _likeLoading = true;
                        _lastIsLiked = isLiked;
                      });
                      await PostLikeService.likeWithAuthCheck(
                          context, widget.postId);
                      setState(() {
                        _likeLoading = false;
                        _lastIsLiked = !isLiked;
                      });
                    },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  HeartAnimationPostAction(
                    animate: _likeLoading || (isLiked != _lastIsLiked),
                    isLiked: isLiked,
                    size: 26,
                    onTap: null,
                  ),
                  //const SizedBox(width: 2),
                  Text(
                    '$likeCount',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    "J'aime",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF212121),
                    ),
                  ),const SizedBox(width: 4),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCommentButton() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('posts').doc(widget.postId).snapshots(),
      builder: (context, snapshot) {
        final commentCount =
            (snapshot.data?.data() as Map<String, dynamic>?)?['commentCount'] ??
                0;
        return InkWell(
          onTap: widget.isCommentPage
              ? null
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostPage(postId: widget.postId),
                    ),
                  );
                },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.mode_comment_outlined,
                //color: Colors.blueAccent,
                size: 24,
              ),
              const SizedBox(width: 6),
              Text(
                '$commentCount',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF212121),
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'Commentaires',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF212121),
                ),
              ),const SizedBox(width: 4),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShareButton() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('posts').doc(widget.postId).snapshots(),
      builder: (context, snapshot) {
        final postData = snapshot.data?.data() as Map<String, dynamic>?;
        final postText = postData?['text']?.toString() ?? '';
        final username = postData?['pseudo']?.toString() ?? 'Un utilisateur';
        
        return InkWell(
          onTap: () async {
            // Création d'un lien profond vers le post
            final deepLink = 'https://vote.app/post/${widget.postId}';
            
            final text = postText.isNotEmpty 
                ? '$username a partagé : "$postText"\n\nDécouvre ce post sur Vote !\n$deepLink' 
                : 'Découvre ce post sur Vote !\n$deepLink';
                
            await Share.share(
              text,
              subject: 'Partagé ce post',
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: const Icon(
              Icons.send_rounded,
              size: 24,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9), // Rendre le fond légèrement transparent
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildLikeButton(),
            Container(
              height: 24,
              width: 1,
              color: Colors.grey.withOpacity(0.3),
            ),
            _buildCommentButton(),
            Container(
              height: 24,
              width: 1,
              color: Colors.grey.withOpacity(0.3),
            ),
            _buildShareButton(),
          ],
        ),
      ),
    );
  }
}
