import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../INSCRIPTION/custom_gender_roller.dart';
import '../../INSCRIPTION/custom_date_roller.dart';

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
  DateTime? _selectedBirthDate; // Date de naissance sélectionnée (DateTime pour sauvegarde)

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
          
          // Récupérer les données
          final data = userData.data() as Map<String, dynamic>;
          
          setState(() {
            _firstNameController.text = data['first_name'] ?? '';
            _lastNameController.text = data['last_name'] ?? '';
            
            // Gérer dateBirthday : peut être Timestamp ou string (anciennes données)
            final dateBirthday = data['dateBirthday'];
            if (dateBirthday != null) {
              if (dateBirthday is Timestamp) {
                // Nouveau format : Timestamp
                _selectedBirthDate = dateBirthday.toDate();
                final date = _selectedBirthDate!;
                _dateBirthdayController.text = 
                    '${date.day.toString().padLeft(2, '0')}/'
                    '${date.month.toString().padLeft(2, '0')}/'
                    '${date.year}';
              } else if (dateBirthday is String) {
                // Ancien format : string (compatibilité)
                _dateBirthdayController.text = dateBirthday;
                // Essayer de parser la string pour avoir la DateTime
                final parts = dateBirthday.split('/');
                if (parts.length == 3) {
                  try {
                    _selectedBirthDate = DateTime(
                      int.parse(parts[2]),
                      int.parse(parts[1]),
                      int.parse(parts[0]),
                    );
                  } catch (e) {
                    _selectedBirthDate = null;
                  }
                }
              }
            } else {
              _dateBirthdayController.text = '';
              _selectedBirthDate = null;
            }
            
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
    // Tous les champs ne sont pas obligatoires, donc on ne vérifie pas la validation

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final updateData = <String, dynamic>{
          'first_name': _firstNameController.text.trim(),
          'last_name': _lastNameController.text.trim(),
          'gender': _selectedGender,
          'lastUpdated': FieldValue.serverTimestamp(),
        };
        
        // Sauvegarder la date de naissance en Timestamp si disponible
        if (_selectedBirthDate != null) {
          updateData['dateBirthday'] = Timestamp.fromDate(_selectedBirthDate!);
        } else if (_dateBirthdayController.text.trim().isEmpty) {
          // Si vide, supprimer le champ (ou mettre null)
          updateData['dateBirthday'] = null;
        }
        
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update(updateData);

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
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
                    _buildReadOnlyField(_pseudoController, 'Pseudo'),
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

  Widget _buildReadOnlyField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      enabled: false,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        suffixIcon: Icon(Icons.lock, color: Colors.grey.shade500, size: 20),
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
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: (value) => null, // Champ non obligatoire
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: _openBirthDateSelector,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _dateBirthdayController.text.isEmpty 
                    ? 'Sélectionnez une date de naissance' 
                    : _dateBirthdayController.text,
                style: TextStyle(
                  color: _dateBirthdayController.text.isEmpty 
                      ? Colors.grey.shade600 
                      : Colors.black87,
                  fontSize: 16,
                ),
              ),
            ),
            const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  void _openBirthDateSelector() {
    DateTime? initialDate = _selectedBirthDate;
    
    CustomDateRoller.show(
      context,
      initialDate: initialDate ?? DateTime.now().subtract(const Duration(days: 6570)), // ~18 ans par défaut
      minDate: DateTime(1900),
      maxDate: DateTime.now(),
      onDateSelected: (date) {
        setState(() {
          // Stocker la DateTime pour la sauvegarde
          _selectedBirthDate = date;
          // Mettre à jour le TextEditingController pour l'affichage
          _dateBirthdayController.text = 
              '${date.day.toString().padLeft(2, '0')}/'
              '${date.month.toString().padLeft(2, '0')}/'
              '${date.year}';
        });
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

