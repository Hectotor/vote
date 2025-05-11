import 'package:flutter/material.dart';
import 'package:toplyke/COMPONENTS/poll_grid_display.dart';

class PollGridHomeModern extends StatelessWidget {
  final List<Map<String, dynamic>>? blocs;
  final String postId;

  const PollGridHomeModern({
    Key? key,
    required this.blocs,
    required this.postId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PollGridDisplay(
      blocs: blocs ?? [],
      type: blocs?.length == 2 ? 'duel' : 
            blocs?.length == 3 ? 'triple' :
            blocs?.length == 4 ? 'quad' : 'custom',
    );
  }
}
