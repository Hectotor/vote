import 'package:flutter/material.dart';

class GenderStep extends StatefulWidget {
  final TextEditingController genderController;
  final VoidCallback onOpenGenderSelector;
  final bool isLoading;
  final VoidCallback? onNextStep;
  final bool Function() isStepValid;

  const GenderStep({
    Key? key,
    required this.genderController,
    required this.onOpenGenderSelector,
    required this.isLoading,
    required this.isStepValid,
    this.onNextStep,
  }) : super(key: key);

  @override
  _GenderStepState createState() => _GenderStepState();
}

class _GenderStepState extends State<GenderStep> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40), // Espacement depuis le haut
        const Text(
          'Tu es?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,

          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40), // Espacement avant le bouton
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onOpenGenderSelector,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.genderController.text.isEmpty
                                ? 'Choisis ton genre'
                                : widget.genderController.text,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: widget.genderController.text.isEmpty
                                  ? FontWeight.w400
                                  : FontWeight.w500,
                              color: widget.genderController.text.isEmpty
                                  ? Colors.grey.shade600
                                  : const Color(0xFF212121),
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.grey.shade600,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Bouton Suivant
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: widget.isLoading || !widget.isStepValid() ? null : widget.onNextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue[600]!,
                          Colors.blue[900]!
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    curve: Curves.easeInOut,
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      alignment: Alignment.center,
                      child: widget.isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            )
                          : const Text(
                              'Suivant',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Pousse le contenu vers le haut
        const Spacer(),
      ],
    );
  }
}
