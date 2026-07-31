import 'package:flutter_test/flutter_test.dart';
import 'package:wheelboard/services/verification_service.dart';

/// Verification contract parsing and input normalization.
///
/// These cover the pure logic the app owns; the network boundary itself is
/// exercised by the backend suite, which asserts the provider contract.
void main() {
  group('registration normalization', () {
    test('collapses the formatting differences users actually type', () {
      // All three are the same vehicle written three ways.
      expect(normalizeRegistration('gj07 4h 4682'), 'GJ074H4682');
      expect(normalizeRegistration('GJ07-4H-4682'), 'GJ074H4682');
      expect(normalizeRegistration('GJ074H4682'), 'GJ074H4682');
      expect(normalizeRegistration('  up16af0785  '), 'UP16AF0785');
    });

    test('never changes meaningful registration characters', () {
      // Only separators are removed; every alphanumeric survives in order.
      const input = 'MH-12 PC 1003';
      expect(normalizeRegistration(input), 'MH12PC1003');
      expect(
        normalizeRegistration(input).split('').toSet(),
        'MH12PC1003'.split('').toSet(),
      );
    });

    test('accepts plausible registrations', () {
      expect(isPlausibleRegistration('GJ07AH4682'), isTrue);
      expect(isPlausibleRegistration('up16af0785'), isTrue);
      expect(isPlausibleRegistration('MH 12 PC 1003'), isTrue);
    });

    test('rejects input that cannot be a registration', () {
      // Guards a paid provider call from obviously unusable input.
      expect(isPlausibleRegistration(''), isFalse);
      expect(isPlausibleRegistration('   '), isFalse);
      expect(isPlausibleRegistration('ABC'), isFalse);
      expect(isPlausibleRegistration('123456'), isFalse); // no letters
      expect(isPlausibleRegistration('ABCDEF'), isFalse); // no digits
    });
  });

  group('document path helpers', () {
    test('reads the filename from both separator styles', () {
      expect(documentBasename('/storage/emulated/0/dl.jpg'), 'dl.jpg');
      expect(documentBasename(r'C:\Users\me\dl.png'), 'dl.png');
      expect(documentBasename('dl.pdf'), 'dl.pdf');
    });

    test('reads a lowercase extension', () {
      expect(documentExtension('/tmp/DL.JPG'), 'jpg');
      expect(documentExtension('/tmp/scan.HEIC'), 'heic');
      expect(documentExtension('/tmp/no-extension'), '');
    });
  });

  group('VerificationState.fromWire', () {
    test('maps every backend status', () {
      expect(
        VerificationState.fromWire('verified'),
        VerificationState.verified,
      );
      expect(VerificationState.fromWire('pending'), VerificationState.pending);
      expect(
        VerificationState.fromWire('rejected'),
        VerificationState.rejected,
      );
      expect(
        VerificationState.fromWire('temporarily_unavailable'),
        VerificationState.temporarilyUnavailable,
      );
      expect(
        VerificationState.fromWire('not_verified'),
        VerificationState.notVerified,
      );
    });

    test('defaults an unknown status to not verified, never verified', () {
      // Fail closed: a status the app does not understand must never be shown
      // to the user as Verified.
      expect(VerificationState.fromWire(null), VerificationState.notVerified);
      expect(
        VerificationState.fromWire('something_new'),
        VerificationState.notVerified,
      );
    });
  });

  group('VerificationResult parsing', () {
    test('parses a verified DL response', () {
      final result = VerificationResult.fromJson<DrivingLicenceData>(
        {
          'verified': true,
          'status': 'verified',
          'message': 'Driving Licence verified successfully.',
          'canContinueManually': false,
          'verifiedAt': '2026-07-30T10:00:00.000Z',
          'verificationMode': 'auto',
          'data': {
            'licenseNumber': 'HR51XXX900XX2760',
            'name': 'PXXXXXX MAN',
            'expiryDate': '10/02/2030',
            'vehicleClasses': ['LMV', 'MCWG'],
          },
        },
        DrivingLicenceData.fromJson,
      );

      expect(result.verified, isTrue);
      expect(result.state, VerificationState.verified);
      expect(result.canContinueManually, isFalse);
      expect(result.data?.licenseNumber, 'HR51XXX900XX2760');
      expect(result.data?.vehicleClasses, ['LMV', 'MCWG']);
      expect(result.verificationMode, 'auto');
    });

    test('parses a temporarily-unavailable response as not verified', () {
      final result = VerificationResult.fromJson<VehicleRcData>(
        {
          'verified': false,
          'status': 'temporarily_unavailable',
          'reason': 'provider-not-authorized',
          'message':
              'Verification is temporarily unavailable. You can try again or '
                  'submit your details for manual verification.',
          'canContinueManually': true,
        },
        VehicleRcData.fromJson,
      );

      expect(result.verified, isFalse);
      expect(result.state, VerificationState.temporarilyUnavailable);
      // The critical distinction: an availability problem is never presented
      // as the user's document being invalid.
      expect(result.state, isNot(VerificationState.notVerified));
      expect(result.canContinueManually, isTrue);
      // The technical reason is available for logs but is not the user copy.
      expect(result.reason, 'provider-not-authorized');
      expect(result.message, isNot(contains('provider-')));
      expect(result.message, isNot(contains('401')));
    });

    test('parses a verified RC response for form auto-fill', () {
      final result = VerificationResult.fromJson<VehicleRcData>(
        {
          'verified': true,
          'status': 'verified',
          'message': 'RC verified successfully.',
          'canContinueManually': false,
          'data': {
            'registrationNumber': 'UP16AF0785',
            'manufacturer': 'FORD INDIA PVT LTD',
            'model': 'ENDEAVOUR',
            'year': 2011,
            'fuelType': 'DIESEL',
            'seatingCapacity': '7',
            'rcStatus': 'ACTIVE',
            'blacklistStatus': false,
          },
        },
        VehicleRcData.fromJson,
      );

      expect(result.verified, isTrue);
      expect(result.data?.registrationNumber, 'UP16AF0785');
      expect(result.data?.manufacturer, 'FORD INDIA PVT LTD');
      expect(result.data?.year, 2011);
      expect(result.data?.seatingCapacity, '7');
      expect(result.data?.blacklistStatus, isFalse);
    });

    test('tolerates numeric capacities sent as numbers', () {
      final rc = VehicleRcData.fromJson({
        'registrationNumber': 'UP16AF0785',
        'seatingCapacity': 7,
        'year': '2011',
      });

      expect(rc.seatingCapacity, '7');
      expect(rc.year, 2011);
    });

    test('a response with no data does not become verified', () {
      final result = VerificationResult.fromJson<VehicleRcData>(
        {
          'verified': false,
          'status': 'not_verified',
          'message': 'We could not verify this vehicle registration.',
          'canContinueManually': true,
        },
        VehicleRcData.fromJson,
      );

      expect(result.verified, isFalse);
      expect(result.data, isNull);
    });

    test('a missing verified flag is never treated as verified', () {
      // Fail closed on a malformed payload.
      final result = VerificationResult.fromJson<VehicleRcData>(
        {'status': 'verified'},
        VehicleRcData.fromJson,
      );
      expect(result.verified, isFalse);
    });

    test('reports a stored result as alreadyVerified', () {
      final result = VerificationResult.fromJson<DrivingLicenceData>(
        {
          'verified': true,
          'status': 'verified',
          'message': 'Driving Licence verified successfully.',
          'canContinueManually': false,
          'alreadyVerified': true,
          'data': {'licenseNumber': 'HR51XXX900XX2760'},
        },
        DrivingLicenceData.fromJson,
      );

      // Lets the UI show Verified without implying a fresh provider call ran.
      expect(result.alreadyVerified, isTrue);
      expect(result.verified, isTrue);
    });
  });
}
