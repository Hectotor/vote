import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toplyke/navBar.dart';
import 'mail_confirm.dart'; // Assurez-vous que le chemin est correct
import 'change_password_screen.dart'; // Importer le nouveau fichier

class ConfirmationEmailPage extends StatefulWidget {
  final String email;
  final String verificationCode; // Rendre ce champ final
  final bool isPasswordReset;

  ConfirmationEmailPage({
    Key? key, 
    required this.email, 
    required this.verificationCode,
    this.isPasswordReset = false,
  }) : super(key: key);

  @override
  _ConfirmationEmailPageState createState() => _ConfirmationEmailPageState();
}

class _ConfirmationEmailPageState extends State<ConfirmationEmailPage> {
  final List<TextEditingController> _codeControllers = List.generate(
    6, 
    (_) => TextEditingController()
  );
  final List<FocusNode> _codeFocusNodes = List.generate(
    6, 
    (_) => FocusNode()
  );
  String? _errorMessage;
  bool _isLoading = false;
  String? enteredCode;
  bool _isCodeResent = false;
  int _remainingTime = 229; // 3 minutes 49 secondes en secondes
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Démarrer le timer dès le lancement de la page
    _startTimer();
    // Ajouter un listener pour détecter le collage
    for (var controller in _codeControllers) {
      controller.addListener(_handlePastedCode);
    }
  }

  void _handlePastedCode() {
    // Récupérer le texte du premier champ
    String pastedText = _codeControllers[0].text;

    // Vérifier si le texte collé est un code à 6 chiffres
    if (pastedText.length == 6 && int.tryParse(pastedText) != null) {
      // Remplir chaque champ avec un chiffre
      for (int i = 0; i < 6; i++) {
        _codeControllers[i].text = pastedText[i];
        
        // Déplacer le focus si ce n'est pas le dernier champ
        if (i < 5) {
          FocusScope.of(context).requestFocus(_codeFocusNodes[i + 1]);
        }
      }

      // Vérifier le code automatiquement
      _verifyCode();
    }
  }

  void _verifyCode() async {
    // Combiner les 6 chiffres en un seul code
    enteredCode = _codeControllers
        .map((controller) => controller.text)
        .join();

    // Vérifier que tous les champs sont remplis
    if (enteredCode!.length != 6) {
      setState(() {
        _errorMessage = 'Veuillez saisir le code complet';
      });
      return;
    }

    // Commencer le chargement
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Vérifier le code dans Firestore
      var querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: widget.email)
          .where('verificationCode', isEqualTo: enteredCode)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Code correct
        if (widget.isPasswordReset) {
          // Pour la réinitialisation du mot de passe
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChangePasswordPage(
                email: widget.email,
                code: enteredCode!,
              ),
            ),
          );
        } else {
          // Pour la confirmation d'email
          await querySnapshot.docs.first.reference.update({
            'emailVerified': true,
          });
          
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => NavBar()),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Code de vérification incorrect';
        });
      }
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

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  void _resendCode() async {
    setState(() {
      _isLoading = true;
      _remainingTime = 229; // Réinitialiser le temps restant
      _startTimer(); // Démarrer le chronomètre
    });
    try {
      String newVerificationCode = EmailConfirmationService.generateVerificationCode(); // Générer un nouveau code
      await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: widget.email).get().then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          querySnapshot.docs.first.reference.update({
            'verificationCode': newVerificationCode, // Mettre à jour le code dans Firestore
          });
        }
      });
      await EmailConfirmationService.sendConfirmationEmail(widget.email, newVerificationCode); // Envoyer le nouveau code par e-mail
      print('Nouveau code envoyé avec succès');

      // Rediriger vers une nouvelle instance de ConfirmationEmailPage avec le nouveau code
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ConfirmationEmailPage(
          email: widget.email,
          verificationCode: newVerificationCode,
          isPasswordReset: widget.isPasswordReset,
        )),
      );
    } catch (e) {
      print('Erreur lors de la mise à jour du code : $e');
    } finally {
      setState(() {
        _isLoading = false;
        _isCodeResent = true;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var focusNode in _codeFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vérification du code'),
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
              'Entrez le code de vérification',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Le code a été envoyé à ${widget.email}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Champ de code de vérification moderne
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  return Expanded(
                    child: Container(
                      height: 60,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: TextField(
                        controller: _codeControllers[index],
                        focusNode: _codeFocusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.blue[600]!,
                              width: 2,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.length == 1) {
                            // Passer automatiquement au champ suivant
                            if (index < 5) {
                              FocusScope.of(context).requestFocus(_codeFocusNodes[index + 1]);
                            } else {
                              // Dernier champ, vérifier le code
                              _verifyCode();
                            }
                          }
                        },
                        onTap: () {
                          // Sélectionner tout le texte lors du tap pour faciliter le remplacement
                          _codeControllers[index].selection = TextSelection(
                            baseOffset: 0, 
                            extentOffset: _codeControllers[index].text.length
                          );
                        },
                        onSubmitted: (value) {
                          _verifyCode();
                        },
                      ),
                    ),
                  );
                }),
              ),
            ),
            // Message d'erreur
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Colors.red[400],
                    fontSize: 14,
                  ),
                ),
              ),
            const SizedBox(height: 32),
            // Bouton de confirmation
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyCode,
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
            ),
            // Bouton de renvoi de code
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Column(
                children: [
                  Text(
                    'Temps restant: ${_remainingTime ~/ 60}:${(_remainingTime % 60).toString().padLeft(2, '0')}',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  TextButton(
                    onPressed: _isLoading || _remainingTime > 0 ? null : _resendCode,
                    child: Text(
                      'Renvoyer le code',
                      style: TextStyle(
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                  if (_isCodeResent)
                    Text(
                      'Code renvoyé avec succès!',
                      style: TextStyle(color: Colors.green),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
