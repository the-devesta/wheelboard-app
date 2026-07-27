import 'package:flutter_test/flutter_test.dart';
import 'package:wheelboard/utils/format_utils.dart';

/// Locks in that the app formats money and distance identically to the web
/// (`formatUnits.ts`) and never surfaces a binary floating-point artifact.
void main() {
  group('formatDistanceKm', () {
    test('strips the float artifact and trims trailing zeros', () {
      expect(FormatUtils.formatDistanceKm(27.200000000000003), '27.2 km');
    });

    test('whole numbers have no decimals', () {
      expect(FormatUtils.formatDistanceKm(27), '27 km');
      expect(FormatUtils.formatDistanceKm(27.0), '27 km');
    });

    test('keeps meaningful decimals', () {
      expect(FormatUtils.formatDistanceKm(27.25), '27.25 km');
      expect(FormatUtils.formatDistanceKm(252.9), '252.9 km');
    });

    test('unknown is an em dash, never 0 km', () {
      expect(FormatUtils.formatDistanceKm(null), '—');
    });
  });

  group('formatMoney', () {
    test('eliminates the 470.65999999999997 artifact', () {
      expect(FormatUtils.formatMoney(470.65999999999997), '₹470.66');
    });

    test('always two decimals with grouping', () {
      expect(FormatUtils.formatMoney(4750), '₹4,750.00');
      expect(FormatUtils.formatMoney(0), '₹0.00');
    });

    test('unknown is an em dash', () {
      expect(FormatUtils.formatMoney(null), '—');
    });
  });

  group('formatCostPerKm', () {
    test('two decimals', () {
      expect(FormatUtils.formatCostPerKm(13.571428571428573), '₹13.57/km');
    });

    test('unknown is an em dash, never ₹0/km', () {
      expect(FormatUtils.formatCostPerKm(null), '—');
    });
  });

  group('cleanKm', () {
    test('removes the artifact but keeps the number', () {
      expect(FormatUtils.cleanKm(27.200000000000003), 27.2);
      expect(FormatUtils.cleanKm(null), isNull);
    });
  });
}
