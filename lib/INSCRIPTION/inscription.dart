@override

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:toplyke/INSCRIPTION/confirmation_email.dart';
import 'package:toplyke/INSCRIPTION/mail_confirm.dart';
import 'package:toplyke/main.dart';



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
        .collection('pseudos')
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


  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer un mot de passe';
    }

    if (value.length < 6) {
      return 'Mot de passe : minimum 6 caractères.';
    }

    return null;
  }

  Future<void> _register() async {
    print('Méthode _register appelée'); // Log pour vérifier l'appel de la méthode

    // Vérifier la validité du formulaire
    if (!_isFormValid() || _pseudoErrorMessage != null) {
      print('Formulaire invalide ou pseudo déjà utilisé'); // Log pour le statut du formulaire
      return;
    }

    // Validation du mot de passe
    final passwordValidation = _validatePassword(_passwordController.text);
    if (passwordValidation != null) {
      setState(() {
        _errorMessage = passwordValidation;
      });
      print('Validation du mot de passe échouée : $passwordValidation'); // Log d'erreur
      return;
    }

    // Vérifier si les mots de passe correspondent
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Les mots de passe ne correspondent pas.';
      });
      print('Les mots de passe ne correspondent pas'); // Log d'erreur
      return;
    }

    // Commencer le chargement
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Vérifier si l'email est déjà utilisé
      var emailQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: _emailController.text.trim())
          .get();

      if (emailQuery.docs.isNotEmpty) {
        // L'email existe déjà, récupérer les données de l'utilisateur
        var userData = emailQuery.docs.first.data();
        
        if (userData['emailVerified'] == false) {
          // Rediriger vers la page de confirmation si l'email n'est pas vérifié
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ConfirmationEmailPage(
              email: _emailController.text.trim(),
              verificationCode: userData['verificationCode'] ?? '', // Assurez-vous que ce champ existe
            )),
          );
          return;
        } else {
          // Afficher un message si l'email est déjà utilisé et vérifié
          setState(() {
            _errorMessage = 'Cet email est déjà utilisé.';
          });
          return;
        }
      }

      // Créer un utilisateur avec Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      print('Utilisateur créé avec succès : ${userCredential.user!.uid}'); // Log de succès

      // Stocker les informations de l'utilisateur dans Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'email': _emailController.text.trim(),
        'pseudo': _pseudoController.text.trim(),
        'emailVerified': false,
        'verificationCode': EmailConfirmationService.generateVerificationCode(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Générer un code de vérification
      String verificationCode = EmailConfirmationService.generateVerificationCode();

      // Envoi d'un email à l'utilisateur
      await EmailConfirmationService.sendConfirmationEmail(_emailController.text.trim(), verificationCode);

      // Rediriger vers la page de confirmation
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ConfirmationEmailPage(
          email: _emailController.text.trim(),
          verificationCode: verificationCode,
        )),
      );

    } on FirebaseAuthException catch (_) {
        // Gérer d'autres erreurs si nécessaire
    } catch (e) {
      if (e is FirebaseAuthException) {
        setState(() {
          _errorMessage = 'Erreur : ${e.message}';
        });
      } else {
        setState(() {
          _errorMessage = 'Une erreur est survenue. Réessayez.';
        });
      }
      print('Erreur : ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
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
                  // Bouton de test pour la page de confirmation d'e-mail
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (context) => ConfirmationEmailPage(
                            email: _emailController.text, 
                            verificationCode: '123456' // Code de test
                          )
                        )
                      );
                    },
                    child: Text('Tester Confirmation Email'),
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