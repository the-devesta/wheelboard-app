import 'package:flutter_test/flutter_test.dart';
import 'package:wheelboard/models/get_vehicle_model.dart';

/// Vehicle parsing resilience.
///
/// Several vehicle fields come from a free-form JSON blob written by clients,
/// so their runtime types are not guaranteed. Parsing must degrade one FIELD
/// rather than throwing, because rows are mapped in a loop and a throw used to
/// take the whole fleet list down — turning real vehicles into "0 vehicles".
void main() {
  Map<String, dynamic> vehicleJson(Map<String, dynamic> overrides) => {
        'id': 'veh-1',
        'companyId': 'company-a',
        'name': 'Endeavour',
        'model': 'ENDEAVOUR',
        'registrationNumber': 'UP16AF0785',
        ...overrides,
      };

  group('numeric fields tolerate string payloads', () {
    test('parses a numeric year', () {
      final v = Vehicle.fromJson(vehicleJson({'year': 2019}));
      expect(v.manufacturingYear, 2019);
    });

    test('parses a year sent as a string', () {
      // The case that used to throw on `as num?`.
      final v = Vehicle.fromJson(vehicleJson({'year': '2019'}));
      expect(v.manufacturingYear, 2019);
    });

    test('falls back to 0 for an unparseable year instead of throwing', () {
      final v = Vehicle.fromJson(vehicleJson({'year': 'not-a-year'}));
      expect(v.manufacturingYear, 0);
      // The rest of the vehicle still parsed — that is the whole point.
      expect(v.vehicleNumber, 'UP16AF0785');
    });

    test('accepts the legacy manufacturingYear key', () {
      final v = Vehicle.fromJson(vehicleJson({'manufacturingYear': '2015'}));
      expect(v.manufacturingYear, 2015);
    });

    test('parses metrics sent as strings', () {
      final v = Vehicle.fromJson(vehicleJson({
        'metrics': {
          'avgRun': '120.5',
          'tripEfficiency': 18,
          'monthlyUsage': '900',
        },
      }));

      expect(v.avgRun, 120.5);
      expect(v.tripEfficiency, 18);
      expect(v.monthlyUsage, 900);
    });

    test('survives a null metrics block', () {
      final v = Vehicle.fromJson(vehicleJson({'metrics': null}));
      expect(v.avgRun, 0);
      expect(v.monthlyUsage, 0);
    });
  });

  group('identity mapping', () {
    test('reads the backend id', () {
      final v = Vehicle.fromJson(vehicleJson({}));
      expect(v.vehicleId, 'veh-1');
    });

    test('falls back to the legacy vehicleId key', () {
      final json = vehicleJson({})..remove('id');
      json['vehicleId'] = 'legacy-1';
      expect(Vehicle.fromJson(json).vehicleId, 'legacy-1');
    });

    test('never throws on a row missing optional fields', () {
      // A sparse row must still yield a usable vehicle rather than aborting
      // the list it belongs to.
      final v = Vehicle.fromJson({'id': 'veh-2'});
      expect(v.vehicleId, 'veh-2');
      expect(v.manufacturingYear, 0);
      expect(v.vehicleNumber, '');
    });
  });

  group('a malformed row does not destroy the list', () {
    test('mapping a page row-by-row keeps the good rows', () {
      final page = <Map<String, dynamic>>[
        vehicleJson({'id': 'ok-1', 'year': 2019}),
        vehicleJson({'id': 'odd', 'year': 'garbage'}),
        vehicleJson({'id': 'ok-2', 'year': '2021'}),
      ];

      // Mirrors the controller's per-row isolation.
      final parsed = <Vehicle>[];
      for (final row in page) {
        try {
          parsed.add(Vehicle.fromJson(row));
        } catch (_) {
          // skipped
        }
      }

      expect(parsed.length, 3);
      expect(parsed.map((v) => v.vehicleId), ['ok-1', 'odd', 'ok-2']);
      expect(parsed[1].manufacturingYear, 0);
    });
  });
}
