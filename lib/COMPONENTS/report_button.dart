import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toplyke/INSCRIPTION/connexion_screen.dart';
import 'dart:async';

class ReportButton extends StatefulWidget {
  final String postId;
  final bool isDarkMode;

  const ReportButton({
    Key? key,
    required this.postId,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  State<ReportButton> createState() => _ReportButtonState();
}

class _ReportButtonState extends State<ReportButton> {
  bool _isReportVisible = false;
  bool _isReported = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkIfReported();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

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

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isReportVisible = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: Icon(
            Icons.more_vert,
            color: widget.isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () {
            setState(() {
              _isReportVisible = !_isReportVisible;
              if (_isReportVisible) {
                _startTimer();
              }
            });
          },
        ),
        if (_isReportVisible)
          Positioned(
            child: GestureDetector(
              onTap: () {
                _reportPost(context);
              },
              onTapDown: (details) {
                setState(() {
                  _isReportVisible = false;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: widget.isDarkMode ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.flag,
                      color: _isReported ? Colors.red : Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Signaler',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
