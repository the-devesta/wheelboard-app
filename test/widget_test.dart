// Wheelboard smoke + canonical-contract tests.
//
// This file previously contained the untouched `flutter create` boilerplate
// ("Counter increments smoke test"), which pumped `MyApp` and asserted a
// counter widget that has never existed in this application. It failed on
// every run and provided no coverage.
//
// A root-level `MyApp` widget test is NOT appropriate here: `main()` is async
// and performs Firebase initialisation plus other platform-channel setup, so
// pumping the real root in a unit-test binding would exercise plugin
// registration rather than Wheelboard behaviour. Instead this file covers:
//
//   1. an isolated, service-free production widget renders (smoke), and
//   2. the canonical metric contract mapping — the null-vs-zero semantics that
//      the trip/vehicle audit depends on. These are the parsers that decide
//      whether an unknown metric reaches the UI as `null` ("—") or as a
//      misleading `0`.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wheelboard/models/trip_expenses_model.dart';
import 'package:wheelboard/models/vehicle_detail_response_model.dart';
import 'package:wheelboard/widgets/custom_loader.dart';

void main() {
  group('smoke — isolated production widget renders', () {
    testWidgets('CustomLoader builds without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: CustomLoader())),
      );

      expect(find.byType(CustomLoader), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('canonical trip metrics — TripInfo.fromJson', () {
    test('maps a known distance and cost per km', () {
      final info = TripInfo.fromJson({
        'tripCode': 'TRIP-2024-0001',
        'distanceKm': 350,
        'efficiencyPerKm': 13.57,
      });

      expect(info.distanceKm, 350);
      expect(info.efficiencyPerKm, 13.57);
    });

    // Regression: an absent metric must stay null so the UI renders an em dash.
    // Coercing it to 0 here is what made unknown trips display "0 km" / "₹0/km".
    test('keeps an absent distance null rather than defaulting to zero', () {
      final info = TripInfo.fromJson({'tripCode': 'TRIP-2024-0002'});

      expect(info.distanceKm, isNull);
      expect(info.efficiencyPerKm, isNull);
    });

    test('preserves a legitimate zero cost per km', () {
      final info = TripInfo.fromJson({'distanceKm': 100, 'efficiencyPerKm': 0});

      // A real ₹0/km (no expenses recorded against a measured trip) is a
      // meaningful value and must NOT be flattened into "unknown".
      expect(info.efficiencyPerKm, 0);
      expect(info.efficiencyPerKm, isNotNull);
    });
  });

  group('canonical vehicle metrics — VehicleMetrics.fromJson', () {
    test('prefers the explicit costPerKm field over the legacy alias', () {
      final metrics = VehicleMetrics.fromJson({
        'costPerKm': 18,
        'tripEfficiency': 15,
        'avgRun': 250,
        'monthlyUsage': 1200,
      });

      // `tripEfficiency` is a deprecated alias; when both are present the
      // explicitly-named canonical field wins.
      expect(metrics.tripEfficiency, 18);
      expect(metrics.avgRun, 250);
      expect(metrics.monthlyUsage, 1200);
    });

    test('falls back to the tripEfficiency alias for older backends', () {
      final metrics = VehicleMetrics.fromJson({'tripEfficiency': 15});

      expect(metrics.tripEfficiency, 15);
    });

    // Regression: a vehicle with no completed trips returns nulls from the
    // backend. Rendering those as 0 claimed a measured "₹0/km" that no trip
    // supported.
    test('keeps unknown vehicle metrics null instead of zero', () {
      final metrics = VehicleMetrics.fromJson({});

      expect(metrics.tripEfficiency, isNull);
      expect(metrics.avgRun, isNull);
      expect(metrics.monthlyUsage, isNull);
    });

    test('exposes a null costPerKM through the compat accessor', () {
      final compat = VehicleDetailCompat(
        VehicleDetailResponseModel.fromJson({'metrics': <String, dynamic>{}}),
      );

      expect(compat.costPerKM, isNull);
    });

    test('exposes a known costPerKM through the compat accessor', () {
      final compat = VehicleDetailCompat(
        VehicleDetailResponseModel.fromJson({
          'metrics': {'costPerKm': 18},
        }),
      );

      expect(compat.costPerKM, 18);
    });
  });
}
