import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
                  onPressed: widget.isLoading || !widget.isStepValid() ? null : () async {
                    // Comme l'utilisateur est déconnecté après l'inscription, nous devons simplement
                    // afficher le message de vérification d'email et ne pas essayer de vérifier
                    // l'état de l'email
                    
                    // Si c'est la première fois qu'on appuie sur le bouton
                    if (!_isEmailSent) {
                      setState(() {
                        _isEmailSent = true;
                        _confirmationText = '📩 Mail envoyé à ${widget.userEmail}. Clique sur le lien pour activer ton compte ✅';
                      });
                      // Appeler onNextStep pour passer à l'étape suivante (si nécessaire)
                      widget.onNextStep?.call();
                    } else {
                      // Si on a déjà envoyé un email, rappeler à l'utilisateur de vérifier sa boîte mail
                      setState(() {
                        _confirmationText = 'Vérifie ta boîte mail pour activer ton compte';
                      });
                      
                      // Permettre à l'utilisateur de se connecter avec l'email vérifié
                      // en l'envoyant vers l'écran de connexion
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const NavBar()),
                        (route) => false,
                      );
                    }
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
