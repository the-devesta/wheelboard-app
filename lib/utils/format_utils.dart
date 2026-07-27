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

  /// Distance in km, max 2 decimals, trailing zeros trimmed. Mirrors the web
  /// `formatDistanceKm` so both platforms render identically and no binary
  /// float artifact (e.g. 27.200000000000003) ever reaches the UI.
  ///
  ///   27      -> "27 km"
  ///   27.2    -> "27.2 km"
  ///   27.25   -> "27.25 km"
  ///   null    -> "—"   (unknown is never shown as "0 km")
  static String formatDistanceKm(num? value) {
    if (value == null || !value.isFinite) return '—';
    final rounded = (value * 100).round() / 100;
    // Trim trailing zeros: 27.20 -> "27.2", 27.00 -> "27".
    var s = rounded.toStringAsFixed(2);
    if (s.contains('.')) {
      s = s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    }
    return '$s km';
  }

  /// Numeric km with the float artifact removed but no unit.
  static num? cleanKm(num? value) {
    if (value == null || !value.isFinite) return null;
    return (value * 100).round() / 100;
  }

  /// Currency in ₹ with exactly two decimals and Indian grouping. `null` -> "—".
  ///   470.66 -> "₹470.66", 4750 -> "₹4,750.00"
  static String formatMoney(num? value) {
    if (value == null || !value.isFinite) return '—';
    final rounded = (value * 100).round() / 100;
    final formatter = NumberFormat('#,##0.00', 'en_IN');
    return '₹${formatter.format(rounded)}';
  }

  /// Cost per km in ₹/km, 2 decimals. `null` -> "—" (never "₹0/km" for unknown).
  static String formatCostPerKm(num? value) {
    if (value == null || !value.isFinite) return '—';
    final rounded = (value * 100).round() / 100;
    return '₹${rounded.toStringAsFixed(2)}/km';
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
