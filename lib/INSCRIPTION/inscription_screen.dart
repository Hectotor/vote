@override
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:toplyke/main.dart';
import 'package:toplyke/INSCRIPTION/connexion_screen.dart';
import 'popup_email_confirmation.dart';



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
  String? _emailErrorMessage;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _isCheckingPseudo = false;

  @override
  void initState() {
    super.initState();
    _pseudoController.addListener(_updateButtonState);
    _emailController.addListener(_updateButtonState);
    _passwordController.addListener(_updateButtonState);
    _confirmPasswordController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _pseudoController.removeListener(_updateButtonState);
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
        _confirmPasswordController.text.isNotEmpty &&
        _pseudoErrorMessage == null;
  }

  Future<void> _checkPseudoAvailability() async {
    if (_pseudoController.text.isEmpty) return;

    if (!_isCheckingPseudo) {
      setState(() {
        _isCheckingPseudo = true;
      });

      try {
        bool isAvailable = await _isPseudoAvailable(_pseudoController.text.trim());
        setState(() {
          _isCheckingPseudo = false;
          _pseudoErrorMessage = isAvailable ? null : 'Ce pseudo est déjà utilisé';
        });
      } catch (e) {
        setState(() {
          _isCheckingPseudo = false;
          _pseudoErrorMessage = 'Erreur lors de la vérification du pseudo';
        });
      }
    }
  }

  Future<bool> _isPseudoAvailable(String pseudo) async {
    try {
      // Vérifier dans la collection users
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('pseudo', isEqualTo: pseudo.toLowerCase())
          .limit(1)
          .get();

      return querySnapshot.docs.isEmpty;
    } catch (e) {
      print('Erreur lors de la vérification du pseudo : $e');
      throw e;
    }
  }

  Future<void> _register() async {
    if (!_isFormValid()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _emailErrorMessage = null;
    });

    try {
      // Vérifier si l'email est déjà utilisé
      var emailQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: _emailController.text.trim())
          .get();

      if (emailQuery.docs.isNotEmpty) {
        setState(() {
          _isLoading = false;
          _emailErrorMessage = 'Cette adresse e-mail est déjà utilisée';
        });
        return;
      }

      // Vérifier définitivement le pseudo
      bool isPseudoAvailable = await _isPseudoAvailable(_pseudoController.text.trim());
      if (!isPseudoAvailable) {
        setState(() {
          _isLoading = false;
          _pseudoErrorMessage = 'Ce pseudo est déjà utilisé';
        });
        return;
      }

      // Créer un utilisateur avec Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Envoyer l'email de vérification
      await userCredential.user!.sendEmailVerification();

      // Enregistrement des données de l'utilisateur dans Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'email': _emailController.text.trim().toLowerCase(),
        'pseudo': _pseudoController.text.trim(),
        'profilePhotoUrl': '',
        'bio': '',
        'emailVerified': false,
        'createdAt': FieldValue.serverTimestamp(),
        'lastSeen': FieldValue.serverTimestamp(),
        'followersCount': 0,
        'followingCount': 0,
        'postsCount': 0,
      });

      // Initialiser la collection followers
      await FirebaseFirestore.instance.collection('followers').doc(userCredential.user!.uid).set({
        'following': [],
        'followers': [],
      });

      // Initialiser la collection notifications
      await FirebaseFirestore.instance.collection('notifications').doc(userCredential.user!.uid).set({
        'unreadCount': 0,
      });

      // Afficher le popup de confirmation
      await showDialog(
        context: context,
        builder: (context) => EmailConfirmationPopup(
          email: _emailController.text.trim(),
        ),
      );

      // Redirection vers la page de connexion
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ConnexionPage()),
      );

    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Une erreur est survenue lors de l\'inscription';
      });
    }
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer un mot de passe';
    }

    if (value.length < 6) {
      return 'Mot de passe : minimum 6 caractères.';
    }

    if (!RegExp(r'(?=.*[!@#\$%\^&\*])').hasMatch(value)) {
      return 'Le mot de passe doit contenir au moins un caractère spécial';
    }

    return null;
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
                  TextFormField(
                    controller: _pseudoController,
                    onChanged: (value) async {
                      // Remplacer les espaces par des underscores
                      String updatedValue = value.replaceAll(' ', '_');
                      // Empêcher l'utilisation du caractère '|'
                      if (updatedValue.contains('|')) {
                        updatedValue = updatedValue.replaceAll('|', '');
                      }
                      // Vérifier si le premier caractère est un espace ou un underscore
                      if (updatedValue.isNotEmpty && (updatedValue[0] == '_' || updatedValue[0] == ' ')) {
                        updatedValue = updatedValue.substring(1); // Retirer le premier caractère
                      }
                      // Mettre à jour le contrôleur avec la nouvelle valeur
                      _pseudoController.value = TextEditingValue(
                        text: updatedValue,
                        selection: TextSelection.collapsed(offset: updatedValue.length),
                      );
                      _checkPseudoAvailability();
                    },
                    decoration: InputDecoration(
                      labelText: 'Pseudo',
                      labelStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                      ),
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: Colors.grey[400],
                        size: 22,
                      ),
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
                  ),
                  if (_pseudoErrorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, left: 16),
                      child: Text(
                        _pseudoErrorMessage!,
                        style: TextStyle(
                          color: Colors.red[400],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Adresse e-mail',
                    icon: Icons.email_outlined,
                    validator: _validateEmail,
                  ),
                  if (_emailErrorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, left: 16),
                      child: Text(
                        _emailErrorMessage!,
                        style: TextStyle(
                          color: Colors.red[400],
                          fontSize: 14,
                        ),
                      ),
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
                    validator: _validatePassword,
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
                    Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.red[400],
                        fontSize: 14,
                      ),
                    ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading || !_isFormValid() || _pseudoErrorMessage != null || _isCheckingPseudo
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
                                      'S\'inscrire',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Icon(
                                      Icons.person_add_outlined,
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
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      onChanged: onChanged,
      textCapitalization: TextCapitalization.none,
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