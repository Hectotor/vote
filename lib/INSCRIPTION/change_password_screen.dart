import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toplyke/main.dart';
import 'package:toplyke/navBar.dart';

class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String? _errorMessage;
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isPasswordChanged = false;
  final FocusNode _newPasswordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Donne le focus au champ de texte 'Nouveau mot de passe'
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

    // Check if passwords match
    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Les mots de passe ne correspondent pas.';
        _isLoading = false;
      });
      return;
    }

    try {
      User? user = FirebaseAuth.instance.currentUser; // Get the current user
      if (user != null) {
        await user.updatePassword(_newPasswordController.text); // Update password
        setState(() {
          _isPasswordChanged = true;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du changement de mot de passe : ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text('Changer mot de passe'),
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
                _buildTextField(
                  controller: _newPasswordController,
                  label: 'Nouveau mot de passe',
                  focusNode: _newPasswordFocusNode,
                  icon: Icons.lock_outline,
                  obscureText: !_isPasswordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey[400],
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirmer le mot de passe',
                  icon: Icons.lock_outline,
                  obscureText: !_isPasswordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey[400],
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
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
                        'Mot de passe changé avec succès',
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
                                  'Confirmer',
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    FocusNode? focusNode,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[400]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.transparent,
      ),
      obscureText: obscureText,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ce champ ne peut pas être vide';
        }
        return null;
      },
    );
  }
}