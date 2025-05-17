import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmailStep extends StatefulWidget {
  final TextEditingController emailController;
  final FocusNode emailFocusNode;
  final bool isLoading;
  final VoidCallback? onNextStep;
  final bool Function() isStepValid;
  final String? errorText;

  const EmailStep({
    Key? key,
    required this.emailController,
    required this.emailFocusNode,
    required this.isLoading,
    required this.isStepValid,
    this.onNextStep,
    this.errorText,
  }) : super(key: key);

  @override
  _EmailStepState createState() => _EmailStepState();
}

class _EmailStepState extends State<EmailStep> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _errorText;
  bool _isLoading = false;

  bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> _handleNextStep() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorText = null;

      });
    }
    try {
      // Convertir l'email en minuscules avant la vérification
      final email = widget.emailController.text.trim().toLowerCase();
      
      // Mettre à jour le champ de texte avec la valeur en minuscules
      if (mounted) {
        widget.emailController.value = widget.emailController.value.copyWith(
          text: email,
          selection: TextSelection.collapsed(offset: email.length),
        );
      }
      
      // Vérifier si l'email existe déjà dans Firestore
      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      
      if (query.docs.isNotEmpty) {
        // L'email existe déjà dans la base de données
        
        if (mounted) {
          setState(() {
            _errorText = 'Oups, ce compte est déjà utilisé';

            _isLoading = false;
          });
        }
        return;
      }
      
      // Vérifier également avec Firebase Auth
      final List<String> existingEmails = await _auth.fetchSignInMethodsForEmail(email);
      if (existingEmails.isNotEmpty) {
        if (mounted) {
          setState(() {
            _errorText = 'Oups, ce compte est déjà utilisé';

            _isLoading = false;
          });
        }
        return;
      }

      // Si l'email n'existe pas, on passe à l'étape suivante
      if (mounted) {
        setState(() {
          _isLoading = false;
          widget.onNextStep?.call();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorText = 'Oups, une erreur est survenue';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Set focus to the email field when the step is first shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(widget.emailFocusNode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        const Text(
          'Quelle est ton adresse email ?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(),
              const SizedBox(height: 24),
              // Bouton Suivant
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () async {
                    // Vérifier le format de l'email avant de continuer
                    if (!isValidEmail(widget.emailController.text)) {
                      setState(() {
                        _errorText = 'Oups, il y a une erreur dans ton adresse e-mail.';
                      });
                      return;
                    }
                    
                    if (!widget.isStepValid()) return;
                    await _handleNextStep();
                  },
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
                      child: _isLoading
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

  Widget _buildTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.emailController,
          focusNode: widget.emailFocusNode,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[900],
            hintText: 'Entre ton email',
            hintStyle: TextStyle(color: Colors.grey[600], fontSize: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
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
            // Convertir l'email en minuscules
            String lowercase = value.toLowerCase();
            if (value != lowercase) {
              widget.emailController.value = widget.emailController.value.copyWith(
                text: lowercase,
                selection: TextSelection.collapsed(offset: lowercase.length),
              );
            }
            
            // Réinitialiser l'erreur quand l'utilisateur modifie l'email
            if (_errorText != null) {
              setState(() {
                _errorText = null;
              });
            }
          },
        ),
        if (_errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _errorText!,
              style: TextStyle(
                color: Colors.red[400],
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}