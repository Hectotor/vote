import 'package:flutter/material.dart';

class DateSelector extends StatelessWidget {
  final DateTime? selectedDate;
  final VoidCallback onSelectDate;
  final String Function(Duration) formatDuration;
  final VoidCallback onClearDate; // Add a callback for clearing the date

  const DateSelector({
    Key? key,
    required this.selectedDate,
    required this.onSelectDate,
    required this.formatDuration,
    required this.onClearDate, // Add the required parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: 20.0, horizontal: 16), // Add padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
        children: [
          if (selectedDate == null)
            GestureDetector(
              onTap: onSelectDate,
              child: Align(
                alignment:
                    Alignment.centerLeft, // Align button text to the left
                child: Text(
                  'Fin du vote...',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                    fontFamily: 'AvenirNext',
                    color: Colors.grey[500],
                  ),
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onSelectDate,
                    child: Align(
                      alignment: Alignment.centerLeft, // Align text to the left
                      child: Text(
                        'Fin du vote dans: ${formatDuration(selectedDate!.difference(DateTime.now()))}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontFamily: 'AvenirNext', // Set font family
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.clear, color: Colors.red),
                  onPressed: onClearDate, // Call the onClearDate callback
                ),
              ],
            ),
        ],
      ),
    );
  }
}
