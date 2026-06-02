import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/Professional/assigned_trip_controller.dart';
import '../TripDashboard/TripDashboardScreen.dart';
import '../TrackTrip/TrackTripScreen.dart';
import '../../../widgets/custom_loader.dart';

/// Smart router — sends the professional to whichever screen is appropriate
/// based on the current state of their assigned trips.
///
/// Priority:
///   1. Active/in-progress trip  → TrackTripScreen (step=inTransit)
///   2. Pending/scheduled trip   → TrackTripScreen (step=readyToStart / confirmOtp)
///   3. No current trips         → TripDashboardScreen
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

      // 1. Active trip that needs live tracking (in-progress / en-route)
      final active = trips.firstWhereOrNull((t) {
        final s = t.tripStatus.toLowerCase();
        return const {
          'in progress',
          'inprogress',
          'active',
          'ongoing',
          'en route',
          'en-route-to-pickup',
          'arrived-at-pickup',
          'in-progress',
          'awaiting-pod',
          'arrived',
        }.contains(s);
      });

      if (active != null) {
        return TrackTripScreen(tripId: active.tripId);
      }

      // 2. Any pending/upcoming trip — let the step machine handle it
      final next = trips.firstWhereOrNull((t) {
        final s = t.tripStatus.toLowerCase();
        return s != 'completed' &&
            s != 'cancelled' &&
            s != 'done' &&
            s != 'finished';
      });

      if (next != null) {
        return TrackTripScreen(tripId: next.tripId);
      }

      // 3. Nothing active → show dashboard/history
      return const TripDashboardScreen();
    });
  }
}
