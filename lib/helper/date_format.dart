import 'package:intl/intl.dart';

class GlobalDateFormat {
  static DateFormat trDateFormat = DateFormat('d MMM yyyy EEEE','tr_TR');

  static String formatDate(String dateString) {
    DateTime date = DateTime.parse(dateString);
    String formattedDate = DateFormat('dd MMM yyyy EEEE', 'tr_TR').format(date);
    return formattedDate;
  }
}
