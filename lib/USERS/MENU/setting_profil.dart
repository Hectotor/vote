import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../INSCRIPTION/custom_gender_roller.dart';

class SettingProfilePage extends StatefulWidget {
  const SettingProfilePage({Key? key}) : super(key: key);

  @override
  State<SettingProfilePage> createState() => _SettingProfilePageState();
}

class _SettingProfilePageState extends State<SettingProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dateBirthdayController = TextEditingController();
  final _pseudoController = TextEditingController();
  String _selectedGender = '';
  bool _isLoading = false;
  bool _dataLoaded = false;

  // Les options de genre sont définies dans CustomGenderRoller

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dateBirthdayController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userData.exists) {
          // Afficher toutes les données pour débogage
          print('Données utilisateur: ${userData.data()}');
          
          // Récupérer les données
          final data = userData.data() as Map<String, dynamic>;
          
          setState(() {
            _firstNameController.text = data['first_name'] ?? '';
            _lastNameController.text = data['last_name'] ?? '';
            _dateBirthdayController.text = data['dateBirthday'] ?? '';
            
            // Rechercher le pseudo dans différents champs possibles
            if (data.containsKey('pseudo')) {
              _pseudoController.text = data['pseudo'] ?? '';
              print('Pseudo trouvé dans le champ \'pseudo\': ${_pseudoController.text}');
            } else if (data.containsKey('username')) {
              _pseudoController.text = data['username'] ?? '';
              print('Pseudo trouvé dans le champ \'username\': ${_pseudoController.text}');
            } else {
              // Parcourir tous les champs pour trouver un champ qui pourrait contenir le pseudo
              data.forEach((key, value) {
                if ((key.toLowerCase().contains('pseudo') || key.toLowerCase().contains('user') || 
                    key.toLowerCase().contains('name')) && value is String) {
                  print('Champ potentiel pour le pseudo: $key = $value');
                }
              });
              
              _pseudoController.text = '';
            }
            
            _selectedGender = data['gender'] ?? 'Homme';
            _dataLoaded = true;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'first_name': _firstNameController.text.trim(),
          'last_name': _lastNameController.text.trim(),
          'dateBirthday': _dateBirthdayController.text.trim(),
          'pseudo': _pseudoController.text.trim(),
          'gender': _selectedGender,
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil mis à jour !')),
          );
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le profil'),
        centerTitle: true,
      ),
      body: _isLoading && !_dataLoaded
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    _buildTextField(_pseudoController, 'Pseudo'),
                    const SizedBox(height: 16),
                    _buildTextField(_firstNameController, 'Prénom'),
                    const SizedBox(height: 16),
                    _buildTextField(_lastNameController, 'Nom'),
                    const SizedBox(height: 16),
                    _buildDateField(),
                    const SizedBox(height: 16),
                    _buildGenderSelector(),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: EdgeInsets.zero,
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue.shade600, Colors.blue.shade900],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            height: 56,
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Text(
                                        'Enregistrer',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Icon(Icons.save, color: Colors.white),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade600),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: (value) =>
          (value == null || value.isEmpty) ? 'Veuillez entrer votre $label' : null,
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: _dateBirthdayController,
      keyboardType: TextInputType.number,
      maxLength: 10,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        _DateInputFormatter(),
      ],
      decoration: InputDecoration(
        labelText: 'Date de naissance (jj/mm/aaaa)',
        counterText: '',
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade600),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintText: 'jj/mm/aaaa',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez saisir une date';
        }
        try {
          final parsedDate = DateFormat('dd/MM/yyyy').parseStrict(value);
          final now = DateTime.now();
          if (parsedDate.isAfter(now)) {
            return 'La date ne peut pas être dans le futur';
          }
          if (parsedDate.isBefore(DateTime(1900))) {
            return 'La date est trop ancienne';
          }
        } catch (e) {
          return 'Format invalide (jj/mm/aaaa)';
        }
        return null;
      },
    );
  }

Widget _buildGenderSelector() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      GestureDetector(
        onTap: () {
          _openGenderSelector();
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _selectedGender.isEmpty ? 'Sélectionnez un genre' : _selectedGender,
                  style: TextStyle(
                    color: _selectedGender.isEmpty ? Colors.grey.shade600 : Colors.black87,
                    fontSize: 16,
                  ),
                ),
              ),
              const Icon(Icons.arrow_drop_down, color: Colors.grey),
            ],
          ),
        ),
      ),
    ],
  );
}

void _openGenderSelector() {
  CustomGenderRoller.show(
    context,
    initialGender: _selectedGender.isNotEmpty ? _selectedGender : 'Femme',
    onGenderSelected: (gender) {
      setState(() {
        _selectedGender = gender;
      });
    },
  );
}
}

class _DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < digitsOnly.length; i++) {
      buffer.write(digitsOnly[i]);
      if ((i == 1 || i == 3) && i != digitsOnly.length - 1) buffer.write('/');
    }
    return newValue.copyWith(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
