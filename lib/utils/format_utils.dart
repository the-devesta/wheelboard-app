import 'package:intl/intl.dart';

class FormatUtils {
  static String formatAmount(num? amount, {String symbol = '₹'}) {
    if (amount == null) return '${symbol}0';
    try {
      final formatter = NumberFormat('#,##0', 'en_IN');
      return '$symbol${formatter.format(amount)}';
    } catch (e) {
      return '$symbol$amount';
    }
  }

  static String formatDate(
    dynamic date, {
    String format = 'dd MMM yyyy, hh:mm a',
  }) {
    if (date == null) return '';
    try {
      DateTime dateTime;
      if (date is DateTime) {
        dateTime = date;
      } else if (date is String) {
        dateTime = DateTime.parse(date).toLocal();
      } else {
        return '';
      }
      return DateFormat(format).format(dateTime);
    } catch (e) {
      return '';
    }
  }
}
