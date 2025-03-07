import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toplyke/main.dart';
import 'package:toplyke/navBar.dart';

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
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
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
      // Utiliser confirmPasswordReset au lieu de updatePassword
      await FirebaseAuth.instance.confirmPasswordReset(
        code: widget.code,
        newPassword: _newPasswordController.text,
      );
      
      setState(() {
        _isPasswordChanged = true;
      });
      
      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Votre mot de passe a été réinitialisé avec succès'),
          duration: Duration(seconds: 3),
        ),
      );

      // Rediriger vers la page de connexion après un court délai
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
      });
    } catch (e) {
      setState(() {
        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'expired-action-code':
              _errorMessage = 'Le code de réinitialisation a expiré. Veuillez recommencer le processus.';
              break;
            case 'invalid-action-code':
              _errorMessage = 'Le code de réinitialisation est invalide. Veuillez recommencer le processus.';
              break;
            case 'weak-password':
              _errorMessage = 'Le mot de passe est trop faible. Veuillez en choisir un plus fort.';
              break;
            default:
              _errorMessage = 'Une erreur est survenue. Veuillez réessayer.';
          }
        } else {
          _errorMessage = 'Une erreur inattendue est survenue. Veuillez réessayer.';
        }
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text('Réinitialiser le mot de passe'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                TextFormField(
                  controller: _newPasswordController,
                  focusNode: _newPasswordFocusNode,
                  obscureText: !_isNewPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Nouveau Mot de Passe',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isNewPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey[400],
                      ),
                      onPressed: () {
                        setState(() {
                          _isNewPasswordVisible = !_isNewPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le champ est vide';
                    }
                    if (value.length < 6) {
                      return 'Le mot de passe doit contenir au moins 6 caractères';
                    }
                    if (!RegExp(r'(?=.*[!@#\$%\^&\*])').hasMatch(value)) {
                      return 'Le mot de passe doit contenir au moins un caractère spécial';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Confirmer le mot de passe',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
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
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
                if (_isPasswordChanged)
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        'Mot de passe réinitialisé avec succès',
                        style: TextStyle(color: Colors.green, fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => NavBar()), // Navigate to home
                          );
                        },
                        child: Text('Retour à l\'accueil'),
                      ),
                    ],
                  ),
                const SizedBox(height: 30),
                AnimatedContainer(
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
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          )
                        : GestureDetector(
                            onTap: _changePassword, // Call the change password method
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Réinitialiser',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}