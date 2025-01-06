import 'package:flutter/material.dart';

class DateSelector extends StatefulWidget {
  final DateTime? selectedDate;
  final String Function(Duration) formatDuration;

  const DateSelector({
    Key? key,
    required this.selectedDate,
    required this.formatDuration,
  }) : super(key: key);

  @override
  _DateSelectorState createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  DateTime? _selectedDate;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
  }

  void _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      locale: const Locale('fr', 'FR'),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: const Color(0xFF4B6CB7), // Couleur principale
              onPrimary:
                  Colors.white, // Couleur du texte sur le bouton sélectionné
              surface: const Color(0xFF1D1D2C), // Couleur de fond du dialogue
              onSurface: Colors.white, // Couleur du texte sur le fond
            ),
            dialogBackgroundColor: const Color(0xFF24243E), // Fond du dialogue
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.dark(
                primary: const Color(0xFF4B6CB7),
                onPrimary: Colors.white,
                surface: const Color(0xFF1D1D2C),
                onSurface: Colors.white,
              ),
              dialogBackgroundColor: const Color(0xFF24243E),
            ),
            child: child!,
          );
        },
      );
      if (time != null) {
        final selectedDateTime = DateTime(
            picked.year, picked.month, picked.day, time.hour, time.minute);
        if (selectedDateTime.isAfter(DateTime.now())) {
          setState(() {
            _selectedDate = selectedDateTime;
            _errorMessage = null;
          });
        } else {
          setState(() {
            _errorMessage = 'Veuillez sélectionner une heure valide.';
          });
          Future.delayed(const Duration(seconds: 5), () {
            setState(() {
              _errorMessage = null;
            });
          });
        }
      }
    }
  }

  void _clearDate() {
    setState(() {
      _selectedDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selectedDate == null)
          GestureDetector(
            onTap: _showDatePicker,
            child: Text(
              'Fin du vote...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w300,
                fontFamily: 'AvenirNext',
                color: Colors.grey[400],
              ),
            ),
          )
        else
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _showDatePicker,
                  child: Text(
                    'Fin du vote dans: ${widget.formatDuration(_selectedDate!.difference(DateTime.now()))}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'AvenirNext',
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.clear),
                color: Colors.redAccent,
                onPressed: _clearDate,
              ),
            ],
          ),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            ),
          ),
      ],
    );
  }
}
