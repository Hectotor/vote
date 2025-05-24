import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toplyke/navBar.dart';

class PasswordStep extends StatefulWidget {
  final TextEditingController passwordController;
  final FocusNode passwordFocusNode;
  final bool isLoading;
  final VoidCallback? onNextStep;
  final bool Function() isStepValid;
  final String userEmail;

  const PasswordStep({
    Key? key,
    required this.passwordController,
    required this.passwordFocusNode,
    required this.isLoading,
    required this.isStepValid,
    required this.userEmail,
    this.onNextStep,
  }) : super(key: key);

  @override
  _PasswordStepState createState() => _PasswordStepState();
}

class _PasswordStepState extends State<PasswordStep> {
  bool _obscureText = true;
  bool _isEmailSent = false;
  String? _confirmationText;

  @override
  void initState() {
    super.initState();
    // Set focus to the password field when the step is first shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(widget.passwordFocusNode);
    });
    
    // Ajouter un listener pour mettre u00e0 jour l'UI quand le texte change
    widget.passwordController.addListener(_onPasswordChanged);
  }
  
  @override
  void dispose() {
    widget.passwordController.removeListener(_onPasswordChanged);
    super.dispose();
  }
  
  void _onPasswordChanged() {
    setState(() {
      // Forcer la mise u00e0 jour de l'UI quand le texte change
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        const Text(
          'Crée un mot de passe',
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
              _buildPasswordField(),
              const SizedBox(height: 5),
              if (widget.passwordController.text.isNotEmpty && widget.passwordController.text.length < 6)
                Text(
                  '6 caractères minimum',
                  style: TextStyle(
                    color: Colors.red[400],
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              if (_confirmationText != null)
                Text(
                  _confirmationText!,
                  style: TextStyle(
                    fontSize: 14,
                    color: _confirmationText!.contains('Erreur') ? Colors.red[400] : Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
              // Bouton Terminer
              const SizedBox(height: 24),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  // Le bouton est actif si le mot de passe a au moins 6 caractères
                  onPressed: widget.passwordController.text.length >= 6 
                    ? () async {
                        // Vérifier si c'est la première fois ou non
                        if (!_isEmailSent) {
                          // Première fois: envoyer l'email de vérification
                          try {
                            // Vérifier si un utilisateur est déjà connecté
                            final currentUser = FirebaseAuth.instance.currentUser;
                            
                            if (currentUser != null) {
                              // Envoyer l'email de vérification
                              await currentUser.sendEmailVerification();
                              setState(() {
                                _isEmailSent = true;
                                _confirmationText = '📩 Email envoyé à ${widget.userEmail}';
                              });
                            } else {
                              // Créer un nouvel utilisateur
                              try {
                                // Créer l'utilisateur avec Firebase Auth
                                final userCredential = await FirebaseAuth.instance
                                    .createUserWithEmailAndPassword(
                                  email: widget.userEmail.trim(),
                                  password: widget.passwordController.text.trim(),
                                );
                                
                                // Sauvegarder les informations utilisateur dans Firestore
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(userCredential.user!.uid)
                                    .set({
                                  'userId': userCredential.user!.uid,
                                  'pseudo': widget.userEmail.split('@')[0].toLowerCase(), // Utiliser la partie avant @ comme pseudo par défaut
                                  'email': widget.userEmail.toLowerCase(),
                                  'profilePhotoUrl': '',
                                  'bio': '',
                                  'gender': '',  // Champ vide car non renseigné dans cette version simplifiée
                                  'dateBirthday': '',  // Champ vide car non renseigné dans cette version simplifiée
                                  'emailVerified': false,
                                  'createdAt': Timestamp.now(),
                                  'lastSeen': Timestamp.now(),
                                  'followersCount': 0,
                                  'followingCount': 0,
                                  'postsCount': 0,
                                });
                                
                                // Envoyer l'email de vérification
                                await userCredential.user!.sendEmailVerification();
                                
                                setState(() {
                                  _isEmailSent = true;
                                  _confirmationText = '📩 Email envoyé à ${widget.userEmail}';
                                });
                              } catch (e) {
                                setState(() {
                                  _confirmationText = 'Erreur d\'inscription: ${e.toString()}';
                                });
                              }
                            }
                          } catch (e) {
                            setState(() {
                              _confirmationText = 'Erreur: ${e.toString()}';
                            });
                          }
                        } else {
                          // Deuxième fois: vérifier si l'email a été confirmé
                          setState(() {
                            _confirmationText = 'Vérification en cours...';
                          });
                          
                          try {
                            // Essayer de se connecter avec les identifiants
                            final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                              email: widget.userEmail.trim(),
                              password: widget.passwordController.text.trim(),
                            );
                            
                            final user = userCredential.user;
                            
                            if (user != null) {
                              // Recharger les données utilisateur
                              await user.reload();
                              
                              if (user.emailVerified) {
                                // Email vérifié - rediriger vers l'application
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => const NavBar()),
                                  (route) => false,
                                );
                              } else {
                                // Email non vérifié
                                setState(() {
                                  _confirmationText = 'Email non vérifié. Vérifie ta boîte mail.';
                                });
                              }
                            } else {
                              setState(() {
                                _confirmationText = 'Erreur: Utilisateur non trouvé';
                              });
                            }
                          } catch (e) {
                            setState(() {
                              _confirmationText = 'Erreur de connexion: ${e.toString()}';
                            });
                          }
                        }
                      } 
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
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  'Terminer',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_isEmailSent)
                TextButton(
                  onPressed: () async {
                    try {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        await user.sendEmailVerification();
                        setState(() {
                          _confirmationText = '📨 Nouveau lien envoyé';
                        });
                      }
                    } catch (e) {
                      setState(() {
                        _confirmationText = 'Erreur lors de l\'envoi du nouveau lien : ${e.toString()}';
                      });
                    }
                  },
                  child: Text(
                    'Renvoyer le lien de vérification',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
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

  Widget _buildPasswordField() {
    return TextFormField(
      controller: widget.passwordController,
      focusNode: widget.passwordFocusNode,
      obscureText: _obscureText,
      textInputAction: TextInputAction.done,
      textAlign: TextAlign.center,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[900],
        hintText: 'Au moins 6 caractères',
        hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
        labelStyle: TextStyle(
          color: Colors.grey[400],
          fontSize: 16,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey[400],
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
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
    );
  }
}
