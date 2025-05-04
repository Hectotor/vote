import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'connexion_screen.dart';

class ChangePasswordPage extends StatefulWidget {
  final String email;
  final String code;

  const ChangePasswordPage({
    Key? key,
    required this.email,
    required this.code,
  }) : super(key: key);

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String? _errorMessage;
  bool _isNewPasswordVisible = false; // Déjà false par défaut
  bool _isConfirmPasswordVisible = false; // Déjà false par défaut
  bool _isLoading = false;
  bool _isPasswordChanged = false;
  final FocusNode _newPasswordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_newPasswordFocusNode);
    });
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _newPasswordFocusNode.dispose();
    super.dispose();
  }

  void _changePassword() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Vérification de la correspondance des mots de passe
    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Les mots de passe ne correspondent pas.';
        _isLoading = false;
      });
      return;
    }

    // Vérification de la validité du mot de passe
    if (_newPasswordController.text.isEmpty || _newPasswordController.text.length < 6) {
      setState(() {
        _errorMessage = 'Le mot de passe doit contenir au moins 6 caractères.';
        _isLoading = false;
      });
      return;
    }

    if (!RegExp(r'(?=.*[!@#\$%\^&\*])').hasMatch(_newPasswordController.text)) {
      setState(() {
        _errorMessage = 'Le mot de passe doit contenir au moins un caractère spécial.';
        _isLoading = false;
      });
      return;
    }

    try {
      // Vérifier que le code correspond toujours dans Firestore
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: widget.email)
          .where('verificationCode', isEqualTo: widget.code)
          .get();

      if (userDoc.docs.isEmpty) {
        setState(() {
          _errorMessage = 'Code de vérification invalide ou expiré.';
          _isLoading = false;
        });
        return;
      }

      try {
        // Se connecter avec l'email et le code comme mot de passe temporaire
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: widget.email,
          password: widget.code,
        );
        
        // Mettre à jour le mot de passe
        if (FirebaseAuth.instance.currentUser != null) {
          await FirebaseAuth.instance.currentUser!.updatePassword(_newPasswordController.text);
          
          // Mettre à jour Firestore
          await userDoc.docs.first.reference.update({
            'passwordReset': true,
            'verificationCode': null,
          });

          setState(() {
            _isPasswordChanged = true;
          });

          // Déconnecter l'utilisateur
          await FirebaseAuth.instance.signOut();

          // Rediriger vers la page de connexion après 2 secondes
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => ConnexionPage()),
              (route) => false,
            );
          });
        }
      } catch (authError) {
        print('Erreur d\'authentification: $authError');
        setState(() {
          if (authError is FirebaseAuthException) {
            switch (authError.code) {
              case 'wrong-password':
                _errorMessage = 'Le code de vérification est incorrect.';
                break;
              case 'user-not-found':
                _errorMessage = 'Utilisateur non trouvé.';
                break;
              default:
                _errorMessage = 'Erreur: ${authError.message}';
            }
          } else {
            _errorMessage = 'Une erreur est survenue lors de la mise à jour du mot de passe.';
          }
        });
      }
    } catch (e) {
      print('Erreur détaillée: $e');
      setState(() {
        _errorMessage = 'Une erreur est survenue lors du changement de mot de passe.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nouveau mot de passe'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            Text(
              'Créez votre nouveau mot de passe',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Le mot de passe doit contenir au moins 6 caractères et un caractère spécial.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _newPasswordController,
              focusNode: _newPasswordFocusNode,
              obscureText: !_isNewPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Nouveau mot de passe',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isNewPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey[400],
                  ),
                  onPressed: () {
                    setState(() {
                      _isNewPasswordVisible = !_isNewPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _confirmPasswordController,
              obscureText: !_isConfirmPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Confirmer le mot de passe',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey[400],
                  ),
                  onPressed: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _changePassword,
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
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Changer le mot de passe',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(
                                Icons.lock_reset,
                                color: Colors.white,
                                size: 24,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
            if (_isPasswordChanged)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  'Votre mot de passe a été changé avec succès. Veuillez vous reconnecter.',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}