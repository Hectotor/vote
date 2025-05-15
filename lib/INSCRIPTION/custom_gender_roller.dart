import 'package:flutter/material.dart';

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
    
    // Initialisation de l'index sélectionné
    int selectedIndex = initialGender != null ? genders.indexOf(initialGender) : -1;
    if (selectedIndex < 0) selectedIndex = 0;
    
    // Contrôleur de défilement
    final FixedExtentScrollController controller = FixedExtentScrollController(
      initialItem: selectedIndex,
    );

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Arriu00e8re-plan transparent
      barrierColor: Colors.transparent, // Supprime l'arriu00e8re-plan sombre
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
                bottom: MediaQuery.of(context).padding.bottom + 16,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF000000),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.4),
                    blurRadius: 30,
                    spreadRadius: 0.5,
                    offset: const Offset(0, 10),
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
                      height: 240,
                      child: ListWheelScrollView.useDelegate(
                        controller: controller,
                        itemExtent: 50,
                        physics: const FixedExtentScrollPhysics(),
                        perspective: 0.005,
                        diameterRatio: 1.2,
                        onSelectedItemChanged: (index) {
                          setState(() {
                            selectedIndex = index;
                            onGenderSelected(genders[index]);
                          });
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: genders.length,
                          builder: (context, index) {
                            return Center(
                              child: Text(
                                genders[index],
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: index == selectedIndex 
                                      ? FontWeight.bold 
                                      : FontWeight.normal,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      if (selectedIndex >= 0) {
        onGenderSelected(genders[selectedIndex]);
      }
    });
  }
}
