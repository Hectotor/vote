import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:votely/home/home_page.dart';

class ConfirmationEmailPage extends StatefulWidget {
  final String email;
  final String verificationCode;

  const ConfirmationEmailPage({
    Key? key, 
    required this.email, 
    required this.verificationCode
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

  @override
  void initState() {
    super.initState();
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
    String enteredCode = _codeControllers
        .map((controller) => controller.text)
        .join();

    // Vérifier que tous les champs sont remplis
    if (enteredCode.length != 6) {
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
      if (enteredCode == widget.verificationCode) {
        // Code de vérification correct
        await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: widget.email)
            .get()
            .then((querySnapshot) {
          if (querySnapshot.docs.isNotEmpty) {
            // Mettre à jour le statut de vérification
            querySnapshot.docs.first.reference.update({
              'emailVerified': true,
            });
          }
        });

        // Navigation vers la page suivante
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomePage(), // Remplacez par votre page d'accueil
          ),
        );
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
      // Toujours arrêter le chargement
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  void dispose() {
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
      backgroundColor: Color(0xFF151019),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Titre
                Text(
                  'Confirmation Email',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // Sous-titre
                Text(
                  'Un code de vérification a été envoyé à\n${widget.email}',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
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
                  child: TextButton(
                    onPressed: _isLoading ? null : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Nouveau code en cours d\'envoi...')),
                      );
                    },
                    child: Text(
                      'Renvoyer le code',
                      style: TextStyle(
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
