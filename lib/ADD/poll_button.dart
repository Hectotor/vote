import 'package:flutter/material.dart';

class FloatingPollButton extends StatefulWidget {
  final VoidCallback onPressed;

  const FloatingPollButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  _FloatingPollButtonState createState() => _FloatingPollButtonState();
}

class _FloatingPollButtonState extends State<FloatingPollButton> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Center(
          child: Material(
            elevation: 6,
            shadowColor: const Color(0xFF6A11CB).withOpacity(0.4),
            borderRadius: BorderRadius.circular(50),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF6A11CB), // Violet profond
                    Color(0xFF2575FC), // Bleu électrique
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(50),
              ),
              child: FloatingActionButton.extended(
                onPressed: widget.onPressed,
                elevation: 0,
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                extendedPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                extendedIconLabelSpacing: 12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                materialTapTargetSize: MaterialTapTargetSize.padded,
                icon: const Icon(
                  Icons.poll_outlined,
                  size: 24,
                ),
                label: const Text(
                  'Change Poll',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                isExtended: true,
                extendedTextStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
