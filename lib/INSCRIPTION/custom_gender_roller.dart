import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' show CupertinoPicker, FixedExtentScrollController;

class CustomGenderRoller {
  static Future<void> show(
    BuildContext context, {
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
    
    int selectedIndex = initialGender != null ? genders.indexOf(initialGender) : 0;
    if (selectedIndex == -1) selectedIndex = 0;
    
    String selectedGender = genders[selectedIndex];
    final FixedExtentScrollController scrollController = 
        FixedExtentScrollController(initialItem: selectedIndex);
    // Genre sélectionné par défaut

    // Variable pour stocker le genre sélectionné, accessible via une closure
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isDismissible: true,
      enableDrag: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 16, // Ajoute un padding supplémentaire en bas
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF000000),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.4), // plus doux
                    blurRadius: 30,
                    spreadRadius: 0.5,
                    offset: const Offset(0, 10), // ombre légère vers le bas
                  ),


                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 200,
                      child: CupertinoPicker(
                        scrollController: scrollController,
                        itemExtent: 50,
                        onSelectedItemChanged: (index) {
                          setState(() {
                            selectedGender = genders[index];
                          });
                        },
                        children: List<Widget>.generate(
                          genders.length,
                          (index) => Center(
                            child: Text(
                              genders[index],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24), // Augmenté pour plus d'espace en bas
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      onGenderSelected(selectedGender);
    });
  }
}
