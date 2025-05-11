import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VotePercentages extends StatefulWidget {
  final String postId;
  final int? blocIndex;
  final bool showPercentages;

  const VotePercentages({
    Key? key,
    required this.postId,
    this.blocIndex,
    required this.showPercentages,
  }) : super(key: key);

  @override
  State<VotePercentages> createState() => _VotePercentagesState();
}

class _VotePercentagesState extends State<VotePercentages> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _subscription;
  double _percentage = 0.0;

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
    try {
      final postRef = _firestore.collection('posts').doc(widget.postId);
      final postDoc = await postRef.get();
      
      if (!postDoc.exists) {
        setState(() {
          _percentage = 0.0;
        });
        return;
      }

      final data = postDoc.data()!;
      final blocs = data['blocs'] as List<dynamic>;
      
      // Calculer le nombre total de votes
      int totalVotes = 0;
      for (final bloc in blocs) {
        final voteCount = bloc['voteCount'] as int? ?? 0;
        totalVotes += voteCount;
      }

      // Trouver le bloc spécifique
      final bloc = blocs[widget.blocIndex ?? 0];
      final blocVotes = bloc['voteCount'] as int? ?? 0;
      
      // Calculer le pourcentage
      double percentage = 0.0;
      if (totalVotes > 0) {
        percentage = (blocVotes / totalVotes) * 100;
      }

      setState(() {
        _percentage = percentage;
      });
    } catch (e) {
      print('Erreur lors du chargement des pourcentages: $e');
      setState(() {
        _percentage = 0.0;
      });
    }
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
    if (!widget.showPercentages || _percentage == 0.0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '${_percentage.toStringAsFixed(1)}%',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
