import 'package:get/get.dart';
import 'dart:convert';
import 'package:wheelboard/models/assigned_trip_model.dart';
import 'package:wheelboard/apihelperclass/api_helper.dart';
import 'package:wheelboard/services/auth_service.dart';
import 'package:wheelboard/utils/constants.dart';

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
        print('User not logged in or userId is missing');
        isLoading(false);
        return;
      }

      final response = await HttpHelper.getData(
        endpoint: '${API.getAssignedTrips}$userId',
        headers: {'Authorization': 'Bearer ${_authService.currentToken}'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> tripData = jsonDecode(response.body);
        assignedTrips.value =
            tripData.map((data) => AssignedTrip.fromJson(data)).toList();
      } else {
        print('Failed to load assigned trips: ${response.body}');
      }
    } catch (e) {
      print('Error fetching assigned trips: $e');
    } finally {
      isLoading(false);
    }
  }
}
