import 'package:flutter/material.dart';

class PseudoStep extends StatefulWidget {
  final TextEditingController pseudoController;
  final FocusNode pseudoFocusNode;
  final bool isCheckingPseudo;
  final String? pseudoErrorMessage;
  final Function(String) onPseudoChanged;
  final VoidCallback? onNextStep;

  const PseudoStep({
    Key? key,
    required this.pseudoController,
    required this.pseudoFocusNode,
    required this.isCheckingPseudo,
    required this.pseudoErrorMessage,
    required this.onPseudoChanged,
    this.onNextStep,
  }) : super(key: key);

  @override
  _PseudoStepState createState() => _PseudoStepState();
}

class _PseudoStepState extends State<PseudoStep> {
  @override
  void initState() {
    super.initState();
    // Set focus to the pseudo field when the step is first shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(widget.pseudoFocusNode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        const Text(
          'Choisis ton pseudo',
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
              _buildPseudoField(),
              const SizedBox(height: 5),
              if (widget.pseudoErrorMessage != null)
                Text(
                  widget.pseudoErrorMessage!,
                  style: TextStyle(
                    color: Colors.red[400],
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 24),
              // Bouton Suivant
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: widget.pseudoController.text.isNotEmpty && 
                            widget.pseudoErrorMessage == null &&
                            widget.onNextStep != null
                      ? () => widget.onNextStep!()
                      : null,
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
                          Colors.blue[900]!,
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
                      child: const Text(
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

  Widget _buildPseudoField() {
    return TextFormField(
      controller: widget.pseudoController,
      focusNode: widget.pseudoFocusNode,
      textCapitalization: TextCapitalization.words,
      textAlign: TextAlign.center,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[900],

        hintText: 'Entre ton pseudo',
        hintStyle: TextStyle(color: Colors.white, fontSize: 18),

        suffixIcon: widget.isCheckingPseudo
            ? const Padding(
                padding: EdgeInsets.all(12.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
              )
            : widget.pseudoController.text.isNotEmpty && 
                    widget.pseudoErrorMessage == null
                ? const Icon(Icons.check_circle, color: Colors.green)
                : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.grey[800]!,
            width: 1,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.red[400]!,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.red[400]!,
            width: 1.5,
          ),
        ),
        errorStyle: TextStyle(
          color: Colors.red[400],
        ),
      ),
      onChanged: (value) {
        widget.onPseudoChanged(value);
      },
      onFieldSubmitted: (_) {
        if (widget.pseudoController.text.isNotEmpty && 
            widget.pseudoErrorMessage == null &&
            widget.onNextStep != null) {
          widget.onNextStep!();
        }
      },
    );
  }
}