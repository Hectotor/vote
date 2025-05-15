import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toplyke/INSCRIPTION/multi_step_inscription.dart';
import 'package:toplyke/main.dart';
import 'package:toplyke/navBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toplyke/INSCRIPTION/PasswordReset_mail_screen.dart';
import 'package:toplyke/INSCRIPTION/email_verification_popup.dart';

class ConnexionPage extends StatefulWidget {
  const ConnexionPage({super.key});

  @override
  _ConnexionPageState createState() => _ConnexionPageState();
}

class _ConnexionPageState extends State<ConnexionPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _errorMessage;
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  FocusNode? _emailFocusNode;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_updateButtonState);
    _passwordController.addListener(_updateButtonState);
    _emailFocusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_emailFocusNode);
    });
  }

  @override
  void dispose() {
    _emailController.removeListener(_updateButtonState);
    _passwordController.removeListener(_updateButtonState);
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode?.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    setState(() {});
  }

  bool _isFormValid() {
    return _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty;
  }

  String? _validateEmail(String? value) {
    if (!value!.contains('@')) {
      return 'Entre une adresse e-mail valide';
    }
    return null;
  }

  Future<void> _login() async {
    if (!_isFormValid()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Se connecter avec Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Vérifier si l'email est vérifié
      if (!userCredential.user!.emailVerified) {
        // Afficher le popup pour l'email non vérifié
        await showDialog(
          context: context,
          builder: (context) => EmailVerificationPopup(
            email: _emailController.text.trim(),
            isUnverified: true,
          ),
        );
        
        // Déconnecter l'utilisateur
        await FirebaseAuth.instance.signOut();
        
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Mettre à jour le statut emailVerified dans Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .update({
            'emailVerified': true,
            'lastSeen': FieldValue.serverTimestamp(),
          });

      // Redirection vers la page principale
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const NavBar()),
      );

    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'user-not-found':
            _errorMessage = 'Aucun utilisateur trouvé avec cet email';
            break;
          case 'wrong-password':
            _errorMessage = 'Mot de passe incorrect';
            break;
          default:
            _errorMessage = 'Erreur de connexion. Réessayez.';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Une erreur est survenue. Réessayez.';
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
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const NavBar()),
              );
            },
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Se connecter',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[300],
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Adresse e-mail',
                    icon: Icons.email_outlined,
                    validator: _validateEmail,
                    focusNode: _emailFocusNode,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _passwordController,
                    label: 'Mot de passe',
                    icon: Icons.lock_outline,
                    obscureText: !_isPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey[400],
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PasswordResetPage()),
                        );
                      },
                      child: Text(
                        'Mot de passe oublié ?',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16, left: 16),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.red[400],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading || !_isFormValid() ? null : _login,
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
                                      'Se connecter',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Icon(
                                      Icons.login,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Pas encore de compte ?',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 15,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MultiStepInscription(),
                            ),
                          );
                        },
                        child: const Text(
                          'Créer un compte',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    FocusNode? focusNode,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      validator: validator,
      obscureText: obscureText,
      onChanged: (value) {
        if (label == 'Adresse e-mail') {
          final lowercase = value.toLowerCase();
          if (value != lowercase) {
            controller.value = controller.value.copyWith(
              text: lowercase,
              selection: TextSelection.collapsed(offset: lowercase.length),
            );
          }
        }
      },
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration( 
        filled: true,
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey[400],
          fontSize: 16,
        ),
        prefixIcon: Icon(
          icon,
          color: Colors.grey[400],
          size: 22,
        ),
        suffixIcon: suffixIcon,
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
    );
  }
}
