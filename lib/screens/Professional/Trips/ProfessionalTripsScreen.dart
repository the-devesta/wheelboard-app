import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/Professional/assigned_trip_controller.dart';
import '../TripDashboard/TripDashboardScreen.dart';
import '../TripProgress/TripProgressScreen.dart';
import '../TrackTrip/TrackTripScreen.dart';
import '../../../widgets/custom_loader.dart';

class ProfessionalTripsScreen extends StatelessWidget {
  const ProfessionalTripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final assignedTripController = Get.find<AssignedTripController>();

    return Obx(() {
      if (assignedTripController.isLoading.value) {
        return const Scaffold(body: Center(child: CustomLoader.small()));
      }

      final trips = assignedTripController.assignedTrips;

      // 1. Map statuses (Live tracking)
      final active = trips.firstWhereOrNull((t) {
        final s = t.tripStatus.toLowerCase();
        return [
          'in progress',
          'inprogress',
          'active',
          'ongoing',
          'en route',
        ].contains(s);
      });

      if (active != null) {
        return TrackTripScreen(tripId: active.tripId);
      }

      // 2. Progress/Start statuses (Any non-finished trip)
      final next = trips.firstWhereOrNull((t) {
        final s = t.tripStatus.toLowerCase();
        return s != 'completed' && s != 'cancelled';
      });

      if (next != null) {
        return TripProgressScreen(trip: next);
      }

      // 3. Fallback to Dashboard only if no current/upcoming trips
      return const TripDashboardScreen();
    });
  }
}
