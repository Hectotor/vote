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
            return SafeArea(
              top: false,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF151019),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 1,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 120,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D3748),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
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

                    const SizedBox(height: 16),
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
