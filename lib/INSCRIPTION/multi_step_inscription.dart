import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:toplyke/INSCRIPTION/custom_date_roller.dart';
import 'package:toplyke/INSCRIPTION/custom_gender_roller.dart';
import 'package:toplyke/INSCRIPTION/email_verification_popup.dart';

class MultiStepInscription extends StatefulWidget {
  const MultiStepInscription({Key? key}) : super(key: key);

  @override
  _MultiStepInscriptionState createState() => _MultiStepInscriptionState();
}

class _MultiStepInscriptionState extends State<MultiStepInscription> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  // Contrôleurs
  final TextEditingController _pseudoController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _dateNaissanceController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // États
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _pageController.dispose();
    _pseudoController.dispose();
    _genderController.dispose();
    _dateNaissanceController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    } else if (_currentStep == 4) {
      _register();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    }
  }

  bool _isStepValid() {
    switch (_currentStep) {
      case 0: // Genre
        return _genderController.text.isNotEmpty;
      case 1: // Date de naissance
        return _dateNaissanceController.text.isNotEmpty;
      case 2: // Pseudo
        return _pseudoController.text.length >= 3;
      case 3: // Email
        return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
            .hasMatch(_emailController.text);
      case 4: // Mot de passe
        return _passwordController.text.length >= 6;
      default:
        return false;
    }
  }

  Future<void> _register() async {
    if (!_isStepValid()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Créer l'utilisateur avec Firebase Auth
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Envoyer l'email de vérification
      await userCredential.user!.sendEmailVerification();

      // Sauvegarder les informations supplémentaires dans Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'userId': userCredential.user!.uid,
        'pseudo': _pseudoController.text.toLowerCase(),
        'gender': _genderController.text,
        'email': _emailController.text.toLowerCase(),
        'dateNaissance': _dateNaissanceController.text.trim(),
        'profilePhotoUrl': '',
        'bio': '',
        'emailVerified': false,
        'createdAt': FieldValue.serverTimestamp(),
        'lastSeen': FieldValue.serverTimestamp(),
        'followersCount': 0,
        'followingCount': 0,
        'postsCount': 0,
      });

      // Afficher le popup de vérification d'email
      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => EmailVerificationPopup(
            email: _emailController.text.trim(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'Une erreur est survenue';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Étape ${_currentStep + 1}/5'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_currentStep > 0) {
              _previousStep();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentStep + 1) / 5,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // Étape 1: Genre
                _buildGenderStep(),
                // Étape 2: Date de naissance
                _buildBirthDateStep(),
                // Étape 3: Pseudo
                _buildPseudoStep(),
                // Étape 4: Email
                _buildEmailStep(),
                // Étape 5: Mot de passe
                _buildPasswordStep(),
              ],
            ),
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGenderStep() {
    return Column(
      children: [
        const SizedBox(height: 40), // Espacement depuis le haut
        const Text(
          'Tu es?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40), // Espacement avant le bouton
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    CustomGenderRoller.show(
                      context,
                      initialGender: _genderController.text.isNotEmpty 
                          ? _genderController.text 
                          : 'Homme',
                      onGenderSelected: (gender) {
                        setState(() {
                          _genderController.text = gender;
                        });
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[900],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    _genderController.text.isEmpty
                        ? 'Sélectionner un genre'
                        : _genderController.text,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Bouton Suivant
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading || !_isStepValid() ? null : _nextStep,
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
                          : const Text(
                              'Suivant',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Pousse le contenu vers le haut
        const Spacer(),
      ],
    );
  }

  Widget _buildBirthDateStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Quelle est votre date de naissance ?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              DateTime? initialDate;
              if (_dateNaissanceController.text.isNotEmpty) {
                final parts = _dateNaissanceController.text.split('/');
                if (parts.length == 3) {
                  initialDate = DateTime(
                    int.parse(parts[2]),
                    int.parse(parts[1]),
                    int.parse(parts[0]),
                  );
                }
              }
              
              CustomDateRoller.show(
                context,
                initialDate: initialDate ?? DateTime.now().subtract(const Duration(days: 6570)),
                minDate: DateTime(1900),
                maxDate: DateTime.now(),
                onDateSelected: (date) {
                  setState(() {
                    _dateNaissanceController.text = 
                        '${date.day.toString().padLeft(2, '0')}/'
                        '${date.month.toString().padLeft(2, '0')}/'
                        '${date.year}';
                  });
                },
              );
            },
            child: Text(
              _dateNaissanceController.text.isEmpty
                  ? 'Sélectionner une date'
                  : _dateNaissanceController.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPseudoStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Choisissez un pseudo',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _pseudoController,
            decoration: const InputDecoration(
              labelText: 'Pseudo',
              border: OutlineInputBorder(),
              hintText: 'Entrez votre pseudo',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          if (_pseudoController.text.isNotEmpty && _pseudoController.text.length < 3)
            const Text(
              'Le pseudo doit contenir au moins 3 caractères',
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }

  Widget _buildEmailStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Quelle est votre adresse email ?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
              hintText: 'exemple@email.com',
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordStep() {
    bool _obscureText = true;
    
    return StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Créez un mot de passe',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _passwordController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  border: const OutlineInputBorder(),
                  hintText: 'Au moins 6 caractères',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              if (_passwordController.text.isNotEmpty &&
                  _passwordController.text.length < 6)
                const Text(
                  'Le mot de passe doit contenir au moins 6 caractères',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        );
      },
    );
  }
}
