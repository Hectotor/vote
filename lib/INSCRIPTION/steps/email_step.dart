import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  String? _errorText;
  bool _isLoading = false;

  Future<void> _handleNextStep() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      // Désactiver le bouton pendant le traitement
      if (mounted) {
        setState(() {
          _errorText = null; // Réinitialiser l'erreur
          _isLoading = true;
        });
      }

      // Créer le compte avec Firebase Auth
      final email = widget.emailController.text.trim();

      // Vérifier d'abord si l'email existe déjà
      final List<String> existingEmails = await _auth.fetchSignInMethodsForEmail(email);

      if (existingEmails.isNotEmpty) {
        // L'email existe déjà, vérifier si il est déjà vérifié
        await _checkExistingEmail(email);
      } else {
        // Créer le compte si l'email n'existe pas
        await _createAccount(email);
      }
    } catch (e) {
      // Gérer d'autres erreurs
      if (mounted) {
        setState(() {
          _errorText = 'Une erreur est survenue: $e';
          _isLoading = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _checkExistingEmail(String email) async {
    try {
      final user = await _auth.signInWithEmailAndPassword(
        email: email,
        password: 'temp_password',
      );

      if (user.user?.emailVerified ?? false) {
        // L'email est déjà vérifié, on peut passer à l'étape suivante
        if (mounted) {
          setState(() {
            widget.onNextStep?.call(); // Appeler le callback pour passer à l'étape suivante
          });
        }
      } else {
        // L'email existe mais n'est pas vérifié
        if (mounted) {
          setState(() {
            _errorText = 'Cette adresse email est déjà utilisée mais n\'est pas encore vérifiée. Vérifiez votre email.';
          });
        }
      }
    } catch (e) {
      // Si on ne peut pas se connecter avec le mot de passe temporaire, l'email n'est pas vérifié
      if (mounted) {
        setState(() {
          _errorText = 'Cette adresse email est déjà utilisée mais n\'est pas encore vérifiée. Vérifiez votre email.';
        });
      }
    }
  }

  Future<void> _createAccount(String email) async {
    try {
      // Vérifier une dernière fois si l'email existe déjà
      final List<String> existingEmails = await _auth.fetchSignInMethodsForEmail(email);
      if (existingEmails.isNotEmpty) {
        await _checkExistingEmail(email);
        return;
      }

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: 'temp_password', // Mot de passe temporaire qui sera changé plus tard
      );

      // Vérifier si l'utilisateur a été créé
      if (credential.user == null) {
        throw Exception('Échec de la création du compte');
      }

      // Envoyer l'email de vérification
      try {
        await credential.user?.sendEmailVerification();
        if (mounted) {
          setState(() {
            _errorText = 'Un email de vérification a été envoyé à $email. Veuillez le vérifier.';
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorText = 'Échec de l\'envoi de l\'email de vérification: ${e.toString()}';
            _isLoading = false;
          });
        }
        return;
      }

      // Vérifier si l'email est vérifié
      if (_auth.currentUser?.emailVerified ?? false) {
        // L'email est vérifié, on peut passer à l'étape suivante
        if (mounted) {
          setState(() {
            widget.onNextStep?.call(); // Appeler le callback pour passer à l'étape suivante
          });
        }
      } else {
        // L'email n'est pas encore vérifié
        if (mounted) {
          setState(() {
            _errorText = 'Veuillez vérifier votre email avant de continuer. Nous avons envoyé un lien de vérification à $email';
          });
        }
      }
    } catch (e) {
      if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
        // Si l'email est déjà utilisé, vérifier son état de vérification
        await _checkExistingEmail(email);
      } else {
        if (mounted) {
          setState(() {
            _errorText = 'Échec de la création du compte: ${e.toString()}';
          });
        }
        throw e; // Relancer l'erreur pour que le bloc catch supérieur la gère
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
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[900],
            labelText: 'Adresse e-mail',
            hintText: 'exemple@email.com',
            hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
            labelStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
            ),
            prefixIcon: Icon(
              Icons.email_outlined,
              color: Colors.grey[400],
              size: 22,
            ),
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
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Colors.white,
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
            // Convertir l'email en minuscules
            String lowercase = value.toLowerCase();
            if (value != lowercase) {
              widget.emailController.value = widget.emailController.value.copyWith(
                text: lowercase,
                selection: TextSelection.collapsed(offset: lowercase.length),
              );
            }
          },
        ),
        if (_errorText != null)
          Padding(
            padding: EdgeInsets.only(top: 8.0),
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