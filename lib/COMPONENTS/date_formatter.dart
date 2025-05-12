import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(dynamic date) {
    if (date == null) return 'Maintenant';
    
    DateTime postDate;
    
    if (date is Timestamp) {
      postDate = date.toDate();
    } else if (date is DateTime) {
      postDate = date;
    } else if (date is Map && date['_seconds'] != null) {
      // Cas où la date est un Timestamp sérialisé
      postDate = DateTime.fromMillisecondsSinceEpoch(
        date['_seconds'] * 1000,
        isUtc: true,
      );
    } else {
      return 'Date inconnue';
    }

    final now = DateTime.now();
    final difference = now.difference(postDate);

    if (difference.inDays >= 7) {
      return DateFormat('d MMMM y', 'fr_FR').format(postDate);
    } else if (difference.inDays >= 1) {
      return '${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Maintenant';
    }
  }
}
