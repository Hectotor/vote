import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:toplyke/INSCRIPTION/custom_date_roller.dart';
import 'package:toplyke/INSCRIPTION/custom_gender_roller.dart';
import 'package:toplyke/INSCRIPTION/email_verification_popup.dart';
import 'package:toplyke/INSCRIPTION/steps/pseudo_step.dart';
import 'package:toplyke/INSCRIPTION/steps/gender_step.dart';
import 'package:toplyke/INSCRIPTION/steps/birth_date_step.dart';
import 'package:toplyke/INSCRIPTION/steps/email_step.dart';
import 'package:toplyke/INSCRIPTION/steps/password_step.dart';

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

  bool _isCheckingPseudo = false;
  String? _pseudoErrorMessage;
  
  // Focus nodes pour les champs de texte
  final FocusNode _pseudoFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    
    // Ajouter un listener pour vérifier la disponibilité du pseudo
    _pseudoController.addListener(() {
      if (_pseudoController.text.length >= 3) {
        _checkPseudoAvailability();
      }
    });
    
    // Ouvrir automatiquement les sélecteurs selon l'étape initiale
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_currentStep == 0) {
        _openGenderSelector();
      } else if (_currentStep == 1) {
        _openBirthDateSelector();
      }
    });
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    _pseudoController.dispose();
    _genderController.dispose();
    _dateNaissanceController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    
    // Libérer les focus nodes
    _pseudoFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    
    super.dispose();
  }
  
  // Vérifie si le pseudo est disponible dans Firestore
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
  
  // Vérifie la disponibilité du pseudo et met à jour l'interface
  Future<void> _checkPseudoAvailability() async {
    if (_pseudoController.text.isEmpty) return;

    if (!_isCheckingPseudo) {
      setState(() {
        _isCheckingPseudo = true;
        _pseudoErrorMessage = null;
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
  
  // Méthode pour ouvrir le sélecteur de genre
  void _openGenderSelector() {
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
  }

  // Méthode pour ouvrir le sélecteur de date de naissance
  void _openBirthDateSelector() {
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
  }

  void _nextStep() {
    if (_currentStep < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
      
      // Ouvrir automatiquement les sélecteurs selon l'étape
      if (_currentStep == 0) {
        _openGenderSelector();
      } else if (_currentStep == 1) {
        _openBirthDateSelector();
      } else if (_currentStep == 2) {
        // Focus sur le champ de pseudo
        Future.delayed(const Duration(milliseconds: 400), () {
          _pseudoFocusNode.requestFocus();
        });
      } else if (_currentStep == 3) {
        // Focus sur le champ d'email
        Future.delayed(const Duration(milliseconds: 400), () {
          _emailFocusNode.requestFocus();
        });
      } else if (_currentStep == 4) {
        // Focus sur le champ de mot de passe
        Future.delayed(const Duration(milliseconds: 400), () {
          _passwordFocusNode.requestFocus();
        });
      }
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
        return _pseudoController.text.length >= 3 && _pseudoErrorMessage == null;
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
    return GenderStep(
      genderController: _genderController,
      onOpenGenderSelector: _openGenderSelector,
      isLoading: _isLoading,
      isStepValid: _isStepValid,
      onNextStep: _nextStep,
    );
  }

  Widget _buildBirthDateStep() {
    return BirthDateStep(
      dateNaissanceController: _dateNaissanceController,
      onOpenBirthDateSelector: _openBirthDateSelector,
      isLoading: _isLoading,
      isStepValid: _isStepValid,
      onNextStep: _nextStep,
    );
  }

  Widget _buildPseudoStep() {
    return PseudoStep(
      pseudoController: _pseudoController,
      pseudoFocusNode: _pseudoFocusNode,
      isCheckingPseudo: _isCheckingPseudo,
      pseudoErrorMessage: _pseudoController.text.isNotEmpty && _pseudoController.text.length < 3
          ? 'Le pseudo doit contenir au moins 3 caractères'
          : _pseudoErrorMessage,
      onPseudoChanged: (value) {
        if (value.length >= 3) {
          _checkPseudoAvailability();
        } else {
          setState(() {
            _pseudoErrorMessage = null;
          });
        }
      },
      onNextStep: _isLoading || !_isStepValid() ? null : _nextStep,
    );
  }

  Widget _buildEmailStep() {
    return EmailStep(
      emailController: _emailController,
      emailFocusNode: _emailFocusNode,
      isLoading: _isLoading,
      isStepValid: _isStepValid,
      onNextStep: _nextStep,
    );
  }

  Widget _buildPasswordStep() {
    return PasswordStep(
      passwordController: _passwordController,
      passwordFocusNode: _passwordFocusNode,
      isLoading: _isLoading,
      isStepValid: _isStepValid,
      onNextStep: _nextStep,
    );
  }
}
