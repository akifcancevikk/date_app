import 'package:intl/intl.dart';

class GlobalDateFormat {
  // Shared date format for display.
  static DateFormat trDateFormat = DateFormat('d MMM yyyy EEEE','tr_TR');

  // Parse ISO date strings and return a localized display format.
  static String formatDate(String dateString) {
    DateTime date = DateTime.parse(dateString);
    String formattedDate = DateFormat('dd MMM yyyy EEEE', 'tr_TR').format(date);
    return formattedDate;
  }
}
