import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/Professional/feeds_controller.dart';
import '../../controllers/Transport/job_controller.dart';
import '../../controllers/Transport/main_wrapper_controller.dart';
import '../../controllers/Transport/notification_controller.dart';
import '../../controllers/Transport/user_profile_controller.dart';
import '../../utils/app_logger.dart';
import '../../widgets/app_bottom_nav.dart';
import 'feed_screen.dart';
import 'fleet_screen.dart';
import 'home_screen.dart';
import 'job_screen.dart';
import 'trips_screen.dart';

class CompanyTransportMainWrapper extends StatefulWidget {
  final int initialIndex;
  const CompanyTransportMainWrapper({super.key, this.initialIndex = 0});

  @override
  State<CompanyTransportMainWrapper> createState() =>
      _CompanyTransportMainWrapperState();
}

class _CompanyTransportMainWrapperState
    extends State<CompanyTransportMainWrapper> {
  final MainWrapperController _wrapperController =
      Get.put(MainWrapperController(), permanent: true);

  // IndexedStack keeps every screen alive — no rebuild on tab switch
  final List<Widget> _screens = [
    const HomeScreen(),
    const FleetVehiclesScreen(),
    TripPage(),
    const FeedScreen(),
    const JobsScreen(),
  ];

  @override
  void initState() {
    super.initState();

    if (!Get.isRegistered<NotificationController>()) {
      Get.put(NotificationController(), permanent: true);
    }
    if (!Get.isRegistered<UserProfileController>()) {
      Get.put(UserProfileController(), permanent: true);
    }
    if (!Get.isRegistered<JobController>()) {
      Get.put(JobController(), permanent: true);
    }
    if (!Get.isRegistered<FeedsController>()) {
      Get.put(FeedsController(), permanent: true);
    }

    AppLogger.d('✅ Common controllers initialized in Company wrapper');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _wrapperController.currentTabIndex.value = widget.initialIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: _wrapperController.currentTabIndex.value,
          children: _screens,
        ),
        bottomNavigationBar: AppBottomNav(
          items: companyNavItems,
          currentIndex: _wrapperController.currentTabIndex.value,
          onTap: (i) => _wrapperController.currentTabIndex.value = i,
        ),
      ),
    );
  }
}
