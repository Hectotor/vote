import 'package:flutter/material.dart';

class BirthDateStep extends StatefulWidget {
  final TextEditingController dateBirthdayController;
  final VoidCallback onOpenBirthDateSelector;
  final bool isLoading;
  final VoidCallback? onNextStep;
  final bool Function() isStepValid;

  const BirthDateStep({
    Key? key,
    required this.dateBirthdayController,
    required this.onOpenBirthDateSelector,
    required this.isLoading,
    required this.isStepValid,
    this.onNextStep,
  }) : super(key: key);

  @override
  _BirthDateStepState createState() => _BirthDateStepState();
}

class _BirthDateStepState extends State<BirthDateStep> {
  // Mu00e9thode pour passer u00e0 l'u00e9tape suivante
  void _goToNextStep() {
    // Passer directement u00e0 l'u00e9tape suivante
    if (widget.onNextStep != null) {
      widget.onNextStep!();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        const Text(
          'Quelle est ta date de naissance ?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,

          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
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
                    onTap: widget.onOpenBirthDateSelector,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.dateBirthdayController.text.isEmpty
                                ? 'Sélectionne une date'
                                : widget.dateBirthdayController.text,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: widget.dateBirthdayController.text.isEmpty
                                  ? FontWeight.w400
                                  : FontWeight.w500,
                              color: widget.dateBirthdayController.text.isEmpty
                                  ? Colors.grey.shade600
                                  : const Color(0xFF212121),
                            ),
                          ),
                          Icon(
                            Icons.calendar_today_rounded,
                            color: Colors.grey.shade600,
                            size: 20,
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
                  onPressed: widget.isLoading || !widget.isStepValid() ? null : _goToNextStep,
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
        const Spacer(),
      ],
    );
  }
}
