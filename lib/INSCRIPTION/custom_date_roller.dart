import 'package:flutter/material.dart';

class CustomDateRoller {
  static Future<void> show(
    BuildContext context, {
    required void Function(DateTime) onDateSelected,
    DateTime? initialDate,
    DateTime? minDate,
    DateTime? maxDate,
  }) async {
    final now = DateTime.now();
    
    // S'assurer que la date initiale n'est pas dans le futur
    DateTime currentDate = initialDate ?? DateTime(now.year - 18, now.month, now.day);
    if (currentDate.isAfter(now)) {
      currentDate = now;
    }
    
    // Limites de dates
    final DateTime minDateTime = minDate ?? DateTime(1900, 1, 1);
    final DateTime maxDateTime = maxDate ?? now;
    
    // Listes pour les jours, mois et années
    final List<int> years = List.generate(
      maxDateTime.year - minDateTime.year + 1, 
      (index) => minDateTime.year + index
    ).reversed.toList(); // Années en ordre décroissant
    
    final List<String> months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    
    // Indices sélectionnés initialement
    int selectedYearIndex = years.indexOf(currentDate.year);
    int selectedMonthIndex = currentDate.month - 1;
    int selectedDayIndex = currentDate.day - 1;
    
    // Contrôleurs de défilement
    final FixedExtentScrollController yearController = 
        FixedExtentScrollController(initialItem: selectedYearIndex);
    final FixedExtentScrollController monthController = 
        FixedExtentScrollController(initialItem: selectedMonthIndex);
    final FixedExtentScrollController dayController = 
        FixedExtentScrollController(initialItem: selectedDayIndex);
    
    // Fonction pour obtenir le nombre de jours dans un mois
    int getDaysInMonth(int year, int month) {
      return DateTime(year, month + 1, 0).day;
    }
    
    // Liste initiale des jours
    List<int> days = List.generate(
      getDaysInMonth(currentDate.year, currentDate.month), 
      (index) => index + 1
    );

    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Arriu00e8re-plan transparent
      barrierColor: Colors.transparent, // Arriu00e8re-plan transparent (pas de masque)
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isDismissible: true, // Permet la fermeture en appuyant u00e0 l'extu00e9rieur
      enableDrag: true, // Permet la fermeture par glissement
      useSafeArea: true, // Utilise la zone su00e9curitaire

      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 16,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFf5f5f5),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
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
                      child: Row(
                        children: [
                          // Sélecteur de jour
                          Expanded(
                            child: ListWheelScrollView.useDelegate(
                              controller: dayController,
                              itemExtent: 50,
                              physics: const FixedExtentScrollPhysics(),
                              perspective: 0.005,
                              diameterRatio: 1.2,
                              onSelectedItemChanged: (index) {
                                // Cru00e9er la nouvelle date
                                final newDate = DateTime(
                                  years[selectedYearIndex],
                                  selectedMonthIndex + 1,
                                  days[index],
                                );
                                
                                // Vu00e9rifier si la date est dans le futur
                                if (newDate.isAfter(now)) {
                                  // Revenir u00e0 la su00e9lection pru00e9cu00e9dente
                                  dayController.jumpToItem(selectedDayIndex);
                                  return;
                                }
                                
                                setState(() {
                                  selectedDayIndex = index;
                                  currentDate = newDate;
                                });
                                
                                // Mettre u00e0 jour la date en temps ru00e9el
                                onDateSelected(currentDate);
                              },
                              childDelegate: ListWheelChildBuilderDelegate(
                                childCount: days.length,
                                builder: (context, index) {
                                  return Center(
                                    child: Text(
                                      days[index].toString(),
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: index == selectedDayIndex 
                                            ? FontWeight.bold 
                                            : FontWeight.normal,
                                        color: const Color(0xFF212121),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          
                          // Sélecteur de mois
                          Expanded(
                            child: ListWheelScrollView.useDelegate(
                              controller: monthController,
                              itemExtent: 50,
                              physics: const FixedExtentScrollPhysics(),
                              perspective: 0.005,
                              diameterRatio: 1.2,
                              onSelectedItemChanged: (index) {
                                // Calculer le nombre de jours dans le nouveau mois
                                final newDaysInMonth = getDaysInMonth(years[selectedYearIndex], index + 1);
                                final newDays = List.generate(newDaysInMonth, (i) => i + 1);
                                
                                // Ajuster le jour sélectionné si nécessaire
                                int newDayIndex = selectedDayIndex;
                                if (newDayIndex >= newDays.length) {
                                  newDayIndex = newDays.length - 1;
                                }
                                
                                // Créer la nouvelle date
                                final newDate = DateTime(
                                  years[selectedYearIndex],
                                  index + 1,
                                  newDays[newDayIndex],
                                );
                                
                                // Vérifier si la date est dans le futur
                                if (newDate.isAfter(now)) {
                                  // Revenir à la sélection précédente
                                  monthController.jumpToItem(selectedMonthIndex);
                                  return;
                                }
                                
                                setState(() {
                                  selectedMonthIndex = index;
                                  days = newDays;
                                  
                                  if (selectedDayIndex != newDayIndex) {
                                    selectedDayIndex = newDayIndex;
                                    dayController.jumpToItem(selectedDayIndex);
                                  }
                                  
                                  currentDate = newDate;
                                });
                                
                                // Mettre u00e0 jour la date en temps ru00e9el
                                onDateSelected(currentDate);
                              },
                              childDelegate: ListWheelChildBuilderDelegate(
                                childCount: months.length,
                                builder: (context, index) {
                                  return Center(
                                    child: Text(
                                      months[index],
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: index == selectedMonthIndex 
                                            ? FontWeight.bold 
                                            : FontWeight.normal,
                                        color: const Color(0xFF212121),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          
                          // Sélecteur d'année
                          Expanded(
                            child: ListWheelScrollView.useDelegate(
                              controller: yearController,
                              itemExtent: 50,
                              physics: const FixedExtentScrollPhysics(),
                              perspective: 0.005,
                              diameterRatio: 1.2,
                              onSelectedItemChanged: (index) {
                                // Calculer le nombre de jours dans le mois pour la nouvelle année
                                final newDaysInMonth = getDaysInMonth(years[index], selectedMonthIndex + 1);
                                final newDays = List.generate(newDaysInMonth, (i) => i + 1);
                                
                                // Ajuster le jour sélectionné si nécessaire
                                int newDayIndex = selectedDayIndex;
                                if (newDayIndex >= newDays.length) {
                                  newDayIndex = newDays.length - 1;
                                }
                                
                                // Créer la nouvelle date
                                final newDate = DateTime(
                                  years[index],
                                  selectedMonthIndex + 1,
                                  newDays[newDayIndex],
                                );
                                
                                // Vérifier si la date est dans le futur
                                if (newDate.isAfter(now)) {
                                  // Revenir à la sélection précédente
                                  yearController.jumpToItem(selectedYearIndex);
                                  return;
                                }
                                
                                setState(() {
                                  selectedYearIndex = index;
                                  days = newDays;
                                  
                                  if (selectedDayIndex != newDayIndex) {
                                    selectedDayIndex = newDayIndex;
                                    dayController.jumpToItem(selectedDayIndex);
                                  }
                                  
                                  currentDate = newDate;
                                });
                                
                                // Mettre u00e0 jour la date en temps ru00e9el
                                onDateSelected(currentDate);
                              },
                              childDelegate: ListWheelChildBuilderDelegate(
                                childCount: years.length,
                                builder: (context, index) {
                                  return Center(
                                    child: Text(
                                      years[index].toString(),
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: index == selectedYearIndex 
                                            ? FontWeight.bold 
                                            : FontWeight.normal,
                                        color: const Color(0xFF212121),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
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
    );
    // La date est du00e9ju00e0 mise u00e0 jour en temps ru00e9el, pas besoin de le faire u00e0 nouveau ici
  }
}
