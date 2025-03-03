import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:votely/main.dart';

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
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _inscriptionTerminee = false;
  bool _isLoading = false;

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
        _pseudoErrorMessage = 'Ce pseudo est déjà utilisé';
      });
    } else {
      setState(() {
        _pseudoErrorMessage = null;
      });
    }
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Vérifier si l'e-mail existe déjà
        List<String> signInMethods = await FirebaseAuth.instance
            .fetchSignInMethodsForEmail(_emailController.text);
        
        if (signInMethods.isNotEmpty) {
          setState(() {
            _errorMessage = "Cette adresse e-mail est déjà utilisée";
            _isLoading = false;
          });
          return;
        }

        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Mettre à jour le profil utilisateur avec le pseudo
        await userCredential.user!.updateProfile(
          displayName: _pseudoController.text,
        );

        await userCredential.user!.sendEmailVerification();

        FirebaseAuth.instance.authStateChanges().listen((User? user) async {
          if (user != null && user.emailVerified) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .set({
              'pseudo': _pseudoController.text,
              'email': _emailController.text,
              'createdAt': Timestamp.now(), // Nouvelle ligne pour ajouter la date d'inscription
            });

            Navigator.pop(context);
          }
        });
        setState(() {
          _inscriptionTerminee = true;
          _isLoading = false;
        });
      } on FirebaseAuthException catch (e) {
        setState(() {
          _errorMessage = e.message;
          _isLoading = false;
        });
      }
    }
  }

  String? _validateEmail(String? value) {
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
      return 'Entre un e-mail valide.';
    }
    return null;
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
              Navigator.pop(context);
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
                    'Inscris-toi !',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[300],
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildTextField(
                    controller: _pseudoController,
                    label: 'Pseudo',
                    icon: Icons.person_outline,
                  ),
                  if (_pseudoErrorMessage != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red[400],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _pseudoErrorMessage!,
                              style: TextStyle(
                                color: Colors.red[400],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
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
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirmer le mot de passe',
                    icon: Icons.lock_reset_outlined,
                    obscureText: !_isConfirmPasswordVisible,
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
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Les mots de passe ne correspondent pas';
                      }
                      return null;
                    },
                  ),
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      margin: const EdgeInsets.only(top: 24),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red[400],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: Colors.red[400],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading || !_isFormValid() || _pseudoErrorMessage != null
                          ? null
                          : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            colors: [
                              Colors.deepPurple[600]!, 
                              Colors.purpleAccent[700]!
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        child: Container(
                          width: double.infinity,
                          height: 56,
                          alignment: Alignment.center,
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'S\'inscrire',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: _isFormValid() ? Colors.white : Color(0xFF151019),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: _inscriptionTerminee 
                      ? Text(
                          "🚀 Vérifie ta boite mail ! Un lien t'attend pour confirmer ton compte.",
                          style: TextStyle(
                            color: Colors.grey[100],
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        )
                      : Container(), // N'affiche rien si l'inscription n'est pas terminée
                  ),
                  const SizedBox(height: 24),
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
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      textCapitalization: TextCapitalization.none,
      onChanged: (value) {
        if (label == 'Pseudo' || label == 'Adresse e-mail') {
          final lowercase = value.toLowerCase();
          if (value != lowercase) {
            controller.value = controller.value.copyWith(
              text: lowercase,
              selection: TextSelection.collapsed(offset: lowercase.length),
            );
          }
        }
      },
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
      decoration: InputDecoration(
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
        filled: true,
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
