import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Reusable Location Service for getting current location
class LocationService {
  /// Get current location coordinates
  static Future<Position?> getCurrentPosition() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('❌ Location services are disabled');
        return null;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('❌ Location permissions are denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('❌ Location permissions are permanently denied');
        return null;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print('✅ Current Location: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      print('❌ Error getting current location: $e');
      return null;
    }
  }

  /// Get address from coordinates (reverse geocoding)
  static Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        // Build address string (skip 'name' as it often contains Plus Code)
        List<String> addressParts = [];

        // Skip 'name' field to avoid Plus Codes like "H85V+6RP"
        // Add street only if it doesn't contain Plus Code pattern
        if (place.street != null && place.street!.isNotEmpty) {
          if (!place.street!.contains('+')) {
            addressParts.add(place.street!);
          }
        }
        
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          addressParts.add(place.subLocality!);
        }
        
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }
        
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          addressParts.add(place.administrativeArea!);
        }
        
        if (place.postalCode != null && place.postalCode!.isNotEmpty) {
          addressParts.add(place.postalCode!);
        }

        String address = addressParts.join(', ');
        print('✅ Address: $address');
        return address.isNotEmpty ? address : null;
      }

      return null;
    } catch (e) {
      print('❌ Error getting address: $e');
      return null;
    }
  }

  /// Get current location and convert to address (combined method)
  static Future<String?> getCurrentLocationAddress() async {
    Position? position = await getCurrentPosition();
    if (position == null) return null;

    return await getAddressFromCoordinates(
      position.latitude,
      position.longitude,
    );
  }
}
