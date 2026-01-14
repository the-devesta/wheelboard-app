import 'package:get/get.dart';
import 'dart:convert';
import 'package:wheelboard/models/assigned_trip_model.dart';
import 'package:wheelboard/apihelperclass/api_helper.dart';
import 'package:wheelboard/services/auth_service.dart';
import 'package:wheelboard/utils/constants.dart';
import '../../utils/app_logger.dart';

class AssignedTripController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  var assignedTrips = <AssignedTrip>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAssignedTrips();
  }

  Future<void> fetchAssignedTrips() async {
    try {
      isLoading(true);
      final userId = _authService.currentUserId;
      if (userId.isEmpty) {
        AppLogger.d('⚠️ User not logged in or userId is missing');
        assignedTrips.value = [];
        isLoading(false);
        return;
      }

      AppLogger.d("🚗 Fetching assigned trips for userId: $userId");

      final response = await HttpHelper.getData(
        endpoint: '${API.getTripListByDriver}$userId',
        headers: {
          'Authorization': 'Bearer ${_authService.currentToken}',
          'Accept': 'application/json',
        },
      );

      AppLogger.d("🚗 Assigned trips response status: ${response.statusCode}");
      AppLogger.d(
        "🚗 Assigned trips response body: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}",
      );

      // Check if response is HTML (error page)
      if (response.body.trim().startsWith('<!DOCTYPE') ||
          response.body.trim().startsWith('<html')) {
        AppLogger.d(
          "❌ Server returned HTML instead of JSON - API endpoint may be incorrect",
        );
        assignedTrips.value = [];
        isLoading(false);
        return;
      }

      if (response.statusCode == 200) {
        AppLogger.d("🚗 RAW TRIP DATA: ${response.body}");
        try {
          final List<dynamic> tripData = jsonDecode(response.body);
          if (tripData.isEmpty) {
            AppLogger.d('ℹ️ No assigned trips found for this user');
            assignedTrips.value = [];
          } else {
            assignedTrips.value = tripData
                .map((data) => AssignedTrip.fromJson(data))
                .toList();
            AppLogger.d("✅ Fetched ${assignedTrips.length} assigned trips");
          }
        } catch (parseError) {
          AppLogger.d('❌ Error parsing assigned trips: $parseError');
          // Check if it's an error message
          try {
            final errorData = jsonDecode(response.body);
            final errorMessage =
                errorData['message'] ??
                errorData['error'] ??
                'No bids found for this trip';
            AppLogger.d('ℹ️ $errorMessage');
          } catch (e) {
            AppLogger.d('❌ Failed to parse error message');
          }
          assignedTrips.value = [];
        }
      } else {
        AppLogger.d('❌ Failed to load assigned trips: ${response.statusCode}');
        // Try to parse error message
        try {
          final errorData = jsonDecode(response.body);
          final errorMessage =
              errorData['message'] ??
              errorData['error'] ??
              'Failed to load assigned trips';
          AppLogger.d('ℹ️ $errorMessage');
        } catch (e) {
          AppLogger.d('❌ Response body: ${response.body}');
        }
        assignedTrips.value = [];
      }
    } catch (e) {
      AppLogger.d('❌ Error fetching assigned trips: $e');
      assignedTrips.value = [];
    } finally {
      isLoading(false);
    }
  }
}
