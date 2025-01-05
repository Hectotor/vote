import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InscriptionPage extends StatefulWidget {
  const InscriptionPage({super.key});

  @override
  _InscriptionPageState createState() => _InscriptionPageState();
}

class _InscriptionPageState extends State<InscriptionPage> {
  final TextEditingController _pseudoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _errorMessage;
  String? _pseudoErrorMessage;

  @override
  void initState() {
    super.initState();
    _pseudoController.addListener(_updateButtonState);
    _pseudoController.addListener(_checkPseudoExists);
    _emailController.addListener(_updateButtonState);
    _passwordController.addListener(_updateButtonState);
    _confirmPasswordController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _pseudoController.removeListener(_updateButtonState);
    _pseudoController.removeListener(_checkPseudoExists);
    _emailController.removeListener(_updateButtonState);
    _passwordController.removeListener(_updateButtonState);
    _confirmPasswordController.removeListener(_updateButtonState);
    _pseudoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    setState(() {});
  }

  bool _isFormValid() {
    return _pseudoController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty;
  }

  void _checkPseudoExists() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('pseudo', isEqualTo: _pseudoController.text)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        _pseudoErrorMessage = 'Ce pseudo existe déjà';
      });
    } else {
      setState(() {
        _pseudoErrorMessage = null;
      });
    }
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Send email verification
        await userCredential.user!.sendEmailVerification();

        setState(() {
          _errorMessage =
              'Un email de vérification a été envoyé. Veuillez vérifier votre email.';
        });

        // Wait for email verification
        FirebaseAuth.instance.authStateChanges().listen((User? user) async {
          if (user != null && user.emailVerified) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .set({
              'pseudo': _pseudoController.text,
              'email': _emailController.text,
            });

            Navigator.pop(context);
          }
        });
      } on FirebaseAuthException catch (e) {
        setState(() {
          _errorMessage = e.message;
        });
      }
    }
  }

  void _showErrorMessage(String message) {
    setState(() {
      _errorMessage = message;
    });
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _errorMessage = null;
      });
    });
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer une adresse e-mail';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Veuillez entrer une adresse e-mail valide';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Couleur neutre pour le fond
      appBar: AppBar(
        title: const Text(
          'Inscription',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'AvenirNext', // Updated font family
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        // Center the body content vertically
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Center(
              // Added Center widget
              child: Column(
                mainAxisSize: MainAxisSize.min, // Center the column vertically
                children: [
                  _buildTextField(
                    controller: _pseudoController,
                    label: 'Pseudo',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Adresse e-mail',
                    icon: Icons.email_outlined,
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _passwordController,
                    label: 'Mot de passe',
                    icon: Icons.lock_outline,
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirmer le mot de passe',
                    icon: Icons.lock_reset_outlined,
                    obscureText: true,
                    validator: (value) {
                      if (value != _passwordController.text) {
                        _showErrorMessage(
                            'Les mots de passe ne correspondent pas 😢');
                        return '';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontFamily: 'AvenirNext', // Updated font family
                        ),
                      ),
                    ),
                  const SizedBox(height: 80),
                  ElevatedButton(
                    onPressed: _isFormValid() && _pseudoErrorMessage == null
                        ? _register
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87, // Couleur neutre sombre
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                    ),
                    child: const Text(
                      'S\'inscrire',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'AvenirNext', // Updated font family
                      ),
                    ),
                  ),
                  if (_pseudoErrorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _pseudoErrorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontFamily: 'AvenirNext', // Updated font family
                        ),
                      ),
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
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.black54), // Couleur neutre
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.black12), // Bordure douce
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.black12), // Bordure douce
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide:
              const BorderSide(color: Colors.black54), // Surlignage neutre
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.red), // Bordure d'erreur
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.red), // Bordure d'erreur
        ),
      ),
      style: const TextStyle(
        fontFamily: 'AvenirNext', // Updated font family
        fontWeight: FontWeight.w500,
        fontSize: 16,
        color: Colors.black,
      ),
    );
  }
}
