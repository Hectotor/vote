import 'package:flutter/material.dart';

class BottomAddBloc extends StatelessWidget {
  final bool showPoll;
  final int numberOfPollBlocs;
  final VoidCallback onPressed;

  const BottomAddBloc({
    Key? key,
    required this.showPoll,
    required this.numberOfPollBlocs,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!showPoll || numberOfPollBlocs >= 4) {
      return const SizedBox.shrink();
    }

    return Positioned(
      right: 16,
      top: MediaQuery.of(context).size.height / 2 + 20,
      child: FloatingActionButton(
        mini: true,
        backgroundColor: Colors.grey[900],
        onPressed: onPressed,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}
