import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Un roller custom pour choisir le genre, sans du00e9pendance externe.
/// Utilisation :
///   CustomGenderRoller.show(context, onGenderSelected: (gender) { ... });
class CustomGenderRoller {
  static Future<void> show(BuildContext context, {
    required void Function(String) onGenderSelected,
    String? initialGender,
  }) async {
    // Liste des genres disponibles
    final List<String> genders = [
      'Homme',
      'Femme',
      'Non-binaire',
      'Préfère ne pas dire',
    ];

    // Genre su00e9lectionnu00e9 par du00e9faut
    String selectedGender = initialGender ?? genders[0];

    // Variable pour stocker le genre su00e9lectionnu00e9, accessible via une closure
    String currentGender = selectedGender;

    // Fonction pour mettre u00e0 jour le genre quand la valeur change
    void updateCurrentGender(String gender) {
      currentGender = gender;
    }

    // Affiche le modal et capture sa fermeture
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF151019),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      // Quand le modal est fermu00e9, applique le genre su00e9lectionnu00e9
      isDismissible: true,
      enableDrag: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFF151019),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 1,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              padding: const EdgeInsets.only(top: 10, left: 24, right: 24, bottom: 24),
              child: SizedBox(
                height: 260, // Hauteur ru00e9duite car un seul roller
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // Drag bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 120),
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D3748),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                      ),
                    ),
                    const SizedBox(height: 45),
                    // Le roller de su00e9lection du genre
                    SizedBox(
                      height: 150,
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: genders.indexOf(selectedGender),
                        ),
                        itemExtent: 40,
                        backgroundColor: Colors.transparent,
                        onSelectedItemChanged: (index) {
                          setState(() {
                            selectedGender = genders[index];
                            updateCurrentGender(selectedGender);
                          });
                        },
                        children: [
                          for (final gender in genders)
                            Center(
                              child: Text(
                                gender,
                                style: TextStyle(fontSize: 20, color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Espacement en bas pour une meilleure lisibilitu00e9
                    SizedBox(height: 10)
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      // Quand le modal est fermu00e9, applique le genre su00e9lectionnu00e9
      onGenderSelected(currentGender);
    });
  }
}
