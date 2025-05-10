import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VotePercentages extends StatefulWidget {
  final String postId;
  final int numberOfBlocs;

  const VotePercentages({
    Key? key,
    required this.postId,
    required this.numberOfBlocs,
  }) : super(key: key);

  @override
  State<VotePercentages> createState() => _VotePercentagesState();
}

class _VotePercentagesState extends State<VotePercentages> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _loadVotePercentages();
    _startListeningForUpdates();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _loadVotePercentages() async {
    // Cette mu00e9thode n'est plus utilisu00e9e car nous affichons les pourcentages directement sur les blocs
  }

  void _startListeningForUpdates() {
    _subscription = _firestore
        .collection('posts')
        .doc(widget.postId)
        .snapshots()
        .listen((doc) {
      _loadVotePercentages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class VotePercentage extends StatelessWidget {
  final String postId;
  final int blocIndex;
  final int totalVotes;
  final int blocVotes;

  const VotePercentage({
    Key? key,
    required this.postId,
    required this.blocIndex,
    required this.totalVotes,
    required this.blocVotes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final percentage = totalVotes > 0 ? (blocVotes / totalVotes) * 100 : 0;
    
    return Positioned(
      bottom: 10,
      right: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          '${percentage.toStringAsFixed(1)}%',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
