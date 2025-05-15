import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toplyke/INSCRIPTION/email_verification_popup.dart';

class EmailStep extends StatefulWidget {
  final TextEditingController emailController;
  final FocusNode emailFocusNode;
  final bool isLoading;
  final VoidCallback? onNextStep;
  final Function(String)? onEmailVerificationSent;
  final bool Function() isStepValid;

  const EmailStep({
    Key? key,
    required this.emailController,
    required this.emailFocusNode,
    required this.isLoading,
    required this.isStepValid,
    this.onNextStep,
    this.onEmailVerificationSent,
  }) : super(key: key);

  @override
  _EmailStepState createState() => _EmailStepState();
}

class _EmailStepState extends State<EmailStep> {
  String? _emailErrorMessage;
  bool _isVerifying = false;
  bool _showResendButton = false;
  bool _emailSent = false;
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
                  onPressed: widget.isLoading || _isVerifying || !widget.isStepValid() ? null : () => _sendVerificationAndContinue(context),
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
                      child: widget.isLoading || _isVerifying
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
              // Texte cliquable pour renvoyer le mail de confirmation
              if (_showResendButton)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Center(
                    child: GestureDetector(
                      onTap: _isVerifying ? null : () => _resendVerificationEmail(context),
                      child: _isVerifying
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.green,
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _emailSent ? Icons.check_circle : Icons.refresh,
                                size: 16,
                                color: _emailSent ? Colors.green : Colors.grey[600],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _emailSent ? 'Mail envoyé !' : 'Renvoyer mail de confirmation',
                                style: TextStyle(
                                  color: _emailSent ? Colors.green : Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
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

  // Renvoie un email de vérification pour un compte existant
  Future<void> _resendVerificationEmail(BuildContext context) async {
    final email = widget.emailController.text.trim();
    
    if (email.isEmpty || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return;
    }
    
    setState(() {
      _isVerifying = true;
    });
    
    try {
      // Essayer de se connecter avec un mot de passe bidon
      // Cela va échouer, mais nous permet de récupérer des informations sur l'utilisateur
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: 'password_bidon_pour_test',
      );
    } catch (e) {
      // Envoyer un email de réinitialisation de mot de passe à la place
      // Cela permet d'envoyer un email même si nous ne pouvons pas nous connecter
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        setState(() {
          _emailSent = true;
          _emailErrorMessage = null;  // Effacer le message d'erreur précédent
        });
      } catch (resetError) {
        setState(() {
          _emailErrorMessage = 'Erreur lors de l\'envoi de l\'email: ${resetError.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  // Envoie un email de vérification et continue vers l'étape suivante
  Future<void> _sendVerificationAndContinue(BuildContext context) async {
    // Activer l'indicateur de chargement
    setState(() {
      _isVerifying = true;
    });
    
    final email = widget.emailController.text.trim();
    
    if (email.isEmpty || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return;
    }
    
    try {
      // Créer un utilisateur temporaire pour envoyer l'email de vérification
      // L'utilisateur sera supprimé lors de la création réelle du compte
      UserCredential tempUser = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: 'TemporaryPassword123!', // Mot de passe temporaire qui sera remplacé
      );
      
      // Envoyer l'email de vérification
      await tempUser.user!.sendEmailVerification();
      
      // Afficher le popup de confirmation
      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (context) => EmailVerificationPopup(
            email: email,
          ),
        );
      }
      
      // Supprimer l'utilisateur temporaire
      await tempUser.user!.delete();
      
      // Notifier que l'email a été envoyé (si le callback est fourni)
      if (widget.onEmailVerificationSent != null) {
        widget.onEmailVerificationSent!(email);
      }
      
      // Continuer vers l'étape suivante
      if (widget.onNextStep != null) {
        widget.onNextStep!();
      }
    } catch (e) {
      // Si l'email existe déjà, afficher un message d'erreur sous le champ
      if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
        // Vérifier si le compte est déjà confirmé
        try {
          // Essayer de se connecter avec un mot de passe bidon pour vérifier si l'email est vérifié

          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: 'password_bidon_pour_test',
          );
        } catch (signInError) {
          if (signInError is FirebaseAuthException) {
            // Si l'erreur est 'user-not-found', l'utilisateur n'existe pas (ne devrait pas arriver ici)
            // Si l'erreur est 'wrong-password', l'utilisateur existe mais le mot de passe est incorrect (cas normal)
            // Si l'erreur est 'user-disabled', le compte est désactivé
            if (signInError.code == 'wrong-password') {
              // L'utilisateur existe, vérifier si l'email est vérifié
              User? currentUser = FirebaseAuth.instance.currentUser;
              bool isEmailVerified = currentUser?.emailVerified ?? false;
              
              setState(() {
                _emailErrorMessage = 'Cet email est déjà utilisé.';
                _showResendButton = !isEmailVerified;  // Afficher le bouton si l'email n'est pas vérifié
              });
            } else {
              // Autre erreur, afficher simplement le message standard
              setState(() {
                _emailErrorMessage = 'Cet email est déjà utilisé.';
                _showResendButton = true;  // Par défaut, montrer le bouton
              });
            }
          }
        }
        
        // Ne pas continuer vers l'étape suivante automatiquement
        // L'utilisateur devra cliquer à nouveau sur le bouton s'il veut continuer
      } else {
        // Afficher un message d'erreur sous le champ
        setState(() {
          _emailErrorMessage = 'Erreur lors de l\'envoi de l\'email: ${e.toString()}';
        });
      }
    } finally {
      // Désactiver l'indicateur de chargement
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  Widget _buildTextField() {
    return TextFormField(
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
        errorText: _emailErrorMessage,
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
        final lowercase = value.toLowerCase();
        if (value != lowercase) {
          widget.emailController.value = widget.emailController.value.copyWith(
            text: lowercase,
            selection: TextSelection.collapsed(offset: lowercase.length),
          );
        }
        
        // Réinitialiser le message d'erreur lorsque l'utilisateur modifie l'email
        if (_emailErrorMessage != null) {
          setState(() {
            _emailErrorMessage = null;
          });
        }
      },
    );
  }
}
