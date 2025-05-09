import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toplyke/INSCRIPTION/connexion_screen.dart';
import 'package:toplyke/COMPONENTS/post_delete_service.dart';

class ReportButton extends StatefulWidget {
  final String postId;
  final String userId;

  const ReportButton({
    Key? key,
    required this.postId,
    required this.userId,
  }) : super(key: key);

  @override
  State<ReportButton> createState() => _ReportButtonState();
}

class _ReportButtonState extends State<ReportButton> {
  bool _isReported = false;
  final PostDeleteService _deleteService = PostDeleteService();

  Future<void> _checkIfReported() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final report = await FirebaseFirestore.instance
          .collection('reports')
          .doc(widget.postId)
          .get();

      if (report.exists && report.data() != null) {
        final reporters = report.data()!['reporters'] as List<dynamic>;
        setState(() {
          _isReported = reporters.contains(currentUser.uid);
        });
      }
    } catch (e) {
      print('Erreur lors de la vérification du signalement: $e');
    }
  }

  Future<void> _reportPost(BuildContext context) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ConnexionPage()),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('reports').doc(widget.postId).set({
        'postId': widget.postId,
        'reportCount': FieldValue.increment(1),
        'reporters': FieldValue.arrayUnion([currentUser.uid]),
      }, SetOptions(merge: true));

      setState(() {
        _isReported = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post signalé'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du signalement: $e'),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _checkIfReported();
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white),
      onSelected: (String value) {
        if (value == 'report') {
          _reportPost(context);
        } else if (value == 'delete') {
          _deleteService.deletePost(widget.postId, widget.userId, context);
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'report',
          child: Row(
            children: [
              Icon(
                Icons.flag,
                color: _isReported ? Colors.red : Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                'Signaler',
                style: TextStyle(
                  color: _isReported ? Colors.red : Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              const Icon(
                Icons.delete,
                color: Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                'Supprimer',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.black.withOpacity(0.8),
    );
  }
}
