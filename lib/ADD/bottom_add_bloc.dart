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
      left: 0,
      right: 0,
      top: MediaQuery.of(context).size.height / 2 - 45,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(20),
          ),
          child: InkWell(
            onTap: onPressed,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_circle_outline,
                  size: 20,
                  color: Colors.grey[300],
                ),
                const SizedBox(width: 8),
                Text(
                  'Add Option',
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
