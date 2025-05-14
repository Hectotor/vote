import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Un roller custom pour choisir une date (JJ/MM/AAAA) façon iOS/Android, sans dépendance externe.
/// Utilisation :
///   CustomDateRoller.show(context, onDateSelected: (date) { ... });
class CustomDateRoller {
  static Future<void> show(BuildContext context, {
    required void Function(DateTime) onDateSelected,
    DateTime? initialDate,
    DateTime? minDate,
    DateTime? maxDate,
  }) async {
    final now = DateTime.now();
    final init = initialDate ?? DateTime(2000, 1, 1);
    final min = minDate ?? DateTime(1900, 1, 1);
    final max = maxDate ?? now;

    int selectedDay = init.day;
    int selectedMonth = init.month;
    int selectedYear = init.year;

    // Génère les listes de valeurs
    List<int> years = [for (int y = max.year; y >= min.year; y--) y];
    List<int> months = [for (int m = 1; m <= 12; m++) m];
    List<int> days = [for (int d = 1; d <= _daysInMonth(selectedYear, selectedMonth); d++) d];

    // Variable pour stocker la date actuelle, accessible via une closure
    DateTime currentDate = DateTime(selectedYear, selectedMonth, selectedDay);
    
    // Fonction pour mettre u00e0 jour la date quand les valeurs changent
    void updateCurrentDate() {
      currentDate = DateTime(selectedYear, selectedMonth, selectedDay);
    }
    
    // Affiche le modal et capture sa fermeture
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF151019),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      // Quand le modal est fermu00e9, applique la date su00e9lectionnu00e9e
      isDismissible: true,
      enableDrag: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Met à jour les jours si mois/année changent
            days = [for (int d = 1; d <= _daysInMonth(selectedYear, selectedMonth); d++) d];
            if (!days.contains(selectedDay)) selectedDay = days.last;
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
                height: 360,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Jour
                        _buildPicker(
                          context,
                          items: days,
                          value: selectedDay,
                          label: 'Jour',
                          onChanged: (val) {
                            setState(() => selectedDay = val);
                            updateCurrentDate();
                          },
                        ),
                        SizedBox(width: 28),
                        // Mois
                        _buildPicker(
                          context,
                          items: months,
                          value: selectedMonth,
                          label: 'Mois',
                          onChanged: (val) {
                            setState(() => selectedMonth = val);
                            updateCurrentDate();
                          },
                          itemBuilder: (context, val) => Text(_frenchMonth(val)),
                        ),
                        SizedBox(width: 28),
                        // Année
                        _buildPicker(
                          context,
                          items: years,
                          value: selectedYear,
                          label: 'Année',
                          onChanged: (val) {
                            setState(() => selectedYear = val);
                            updateCurrentDate();
                          },
                        ),
                      ],
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
      // Quand le modal est fermu00e9, applique la date su00e9lectionnu00e9e
      onDateSelected(currentDate);
    });
    

  }

  static Widget _buildPicker(
    BuildContext context, {
    required List<int> items,
    required int value,
    required String label,
    required ValueChanged<int> onChanged,
    Widget Function(BuildContext, int)? itemBuilder,
  }) {
    final controller = FixedExtentScrollController(initialItem: items.indexOf(value));
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        SizedBox(
          width: label == 'Mois' ? 110 : 70,
          height: 120,
          child: CupertinoPicker(
            scrollController: controller,
            itemExtent: 36,

            onSelectedItemChanged: (idx) => onChanged(items[idx]),
            children: [
              for (final val in items)
                itemBuilder != null
                  ? DefaultTextStyle(style: TextStyle(fontSize: 20, color: const Color(0xFFFFFFFF)), child: itemBuilder(context, val))
                  : Text(val.toString(), style: TextStyle(fontSize: 20, color: const Color(0xFFFFFFFF))),
            ],
          ),
        )
      ],
    );
  }

  static int _daysInMonth(int year, int month) {
    if (month == 12) return DateTime(year + 1, 1, 0).day;
    return DateTime(year, month + 1, 0).day;
  }

  static String _frenchMonth(int month) {
    const months = [
      '', 'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    return months[month];
  }
}
