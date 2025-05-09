import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DateFormatter {
  static String formatDate(Timestamp timestamp) {
    final now = DateTime.now();
    final postDate = timestamp.toDate();
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
