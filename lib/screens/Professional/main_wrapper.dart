import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/Professional/assigned_trip_controller.dart';
import '../../core/auth/auth_service.dart';
import '../../utils/app_logger.dart';
import '../../widgets/app_bottom_nav.dart';
import 'FeedsProfessional/FeedsProfessionalScreen.dart';
import 'FindJobs/FindJobsScreen.dart';
import 'JobProgress/JobProgressScreen.dart';
import 'ProfessionalHomePage/ProfessionalHomePageScreen.dart';
import 'Trips/ProfessionalTripsScreen.dart';

class ProfessionalMainWrapper extends StatefulWidget {
  final int initialIndex;
  const ProfessionalMainWrapper({super.key, this.initialIndex = 0});

  @override
  State<ProfessionalMainWrapper> createState() =>
      _ProfessionalMainWrapperState();
}

class _ProfessionalMainWrapperState extends State<ProfessionalMainWrapper> {
  late int _currentIndex;

  // IndexedStack keeps every screen alive — no rebuild on tab switch
  final List<Widget> _screens = [
    const ProfessionalHomePageScreen(),
    const FindJobsScreen(),
    const ProfessionalTripsScreen(),
    const FeedsProfessionalScreen(),
    const JobProgressScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    if (!Get.isRegistered<AssignedTripController>()) {
      Get.put(AssignedTripController(), permanent: true);
      AppLogger.d('✅ AssignedTripController initialized in Professional wrapper');
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await AuthService.to.refreshLoginStatus();
        final tripCtrl = Get.find<AssignedTripController>();
        await tripCtrl.fetchAssignedTrips();
        AppLogger.d('✅ Auth + trips refreshed in Professional wrapper');
      } catch (e) {
        AppLogger.d('⚠️ Could not refresh on startup: $e');
      }
    });
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);

    // Refresh trips when switching to Home or Trips tab
    if (index == 0 || index == 2) {
      try {
        Get.find<AssignedTripController>().fetchAssignedTrips();
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: AppBottomNav(
        items: professionalNavItems,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
