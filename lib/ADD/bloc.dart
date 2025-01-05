import 'package:flutter/material.dart';

class BlocGrid extends StatelessWidget {
  final int numberOfBlocs;
  final VoidCallback onTap;
  final VoidCallback? onDelete; // Callback pour suppression

  const BlocGrid({
    super.key,
    required this.numberOfBlocs,
    required this.onTap,
    this.onDelete,
  });

  Widget _buildBloc({
    bool showDeleteButton = false,
    bool isSingle = false,
  }) {
    return Card(
      //elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                color:
                    const Color(0xFFf7f7f8), // Set background color to #F7F7F8
                child: Center(
                  child: Icon(
                    Icons.add_photo_alternate_outlined,
                    size: isSingle ? 40 : 40,
                    color: Color(0xFFacacad),
                  ),
                ),
              ),
            ),
          ),
          if (showDeleteButton)
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: onDelete,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.redAccent,
                    size: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent, // Set background color to white
      child: Column(
        children: [
          // Première rangée avec blocs 1 et 2
          SizedBox(
            height: numberOfBlocs == 2 ? 300 : 200,
            child: Row(
              children: [
                Expanded(
                  child: _buildBloc(
                    isSingle: numberOfBlocs == 2,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildBloc(
                    isSingle: numberOfBlocs == 2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          // Deuxième rangée avec bloc 3 (centré) ou blocs 3 et 4
          if (numberOfBlocs >= 3)
            SizedBox(
              height: 200,
              child: numberOfBlocs == 3
                  ? SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: _buildBloc(
                        showDeleteButton: true,
                      ),
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: _buildBloc(
                            showDeleteButton: numberOfBlocs == 4 ? false : true,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _buildBloc(
                            showDeleteButton: numberOfBlocs == 4 ? true : false,
                          ),
                        ),
                      ],
                    ),
            ),
        ],
      ),
    );
  }
}
