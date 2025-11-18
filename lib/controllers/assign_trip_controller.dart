import 'dart:convert';

import 'package:get/get.dart';

import '../apihelperclass/api_helper.dart';
import '../models/assign_trip_model.dart';
import '../utils/constants.dart';
import '../widgets/custom_snackbar.dart';

class AssignTripController extends GetxController {
  final isLoading = false.obs;
  final assignBids = <AssignTripBid>[].obs;
  final errorMessage = ''.obs;

  Future<void> fetchAssignTrip(String tripId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await HttpHelper.getData(
        endpoint: '${API.assignTrip}$tripId',
        headers: {
          'accept': '*/*',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        assignBids.value =
            data.map((item) => AssignTripBid.fromJson(item)).toList();
      } else {
        errorMessage.value =
            'Failed to load assignment details (${response.statusCode})';
        SnackBarHelper.error('Failed to load assignment details');
      }
    } catch (e) {
      errorMessage.value = 'Failed to load assignment details';
      SnackBarHelper.error('Failed to load assignment details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  AssignTripBid? getBidById(String bidId) {
    try {
      return assignBids.firstWhere((bid) => bid.bidId == bidId);
    } catch (_) {
      return null;
    }
  }
}


