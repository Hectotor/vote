import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' show CupertinoDatePicker, CupertinoDatePickerMode;

class CustomDateRoller {
  static Future<void> show(
    BuildContext context, {
    required void Function(DateTime) onDateSelected,
    DateTime? initialDate,
    DateTime? minDate,
    DateTime? maxDate,
  }) async {
    final now = DateTime.now();
    final minYear = minDate?.year ?? 1900;
    final maxYear = maxDate?.year ?? now.year;
    
    // S'assurer que la date initiale n'est pas dans le futur
    DateTime safeInitialDate = initialDate ?? now;
    if (safeInitialDate.isAfter(now)) {
      safeInitialDate = now;
    }
    
    DateTime currentDate = safeInitialDate;
    
    // Extraire les composants de date
    int selectedDay = currentDate.day;
    int selectedMonth = currentDate.month;
    int selectedYear = currentDate.year;
    
    void updateCurrentDate() {
      currentDate = DateTime(selectedYear, selectedMonth, selectedDay);
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF000000),
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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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
                      height: 240,
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.date,
                        initialDateTime: currentDate,
                        onDateTimeChanged: (newDate) {
                          // Ne pas autoriser la sélection d'une date future
                          if (newDate.isAfter(now)) {
                            return;
                          }
                          selectedDay = newDate.day;
                          selectedMonth = newDate.month;
                          selectedYear = newDate.year;
                          updateCurrentDate();
                        },
                        minimumYear: minYear,
                        maximumYear: maxYear,
                        maximumDate: now,
                        backgroundColor: Colors.transparent,
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
      onDateSelected(currentDate);
    });
  }
}
