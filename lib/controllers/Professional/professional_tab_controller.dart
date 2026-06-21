import 'package:get/get.dart';

/// Shared tab index for the Professional bottom-nav.
///
/// Exposed via GetX so any descendant (e.g. the home "View All" feeds button)
/// can switch tabs without a brittle `Get.offAll` rebuild.
class ProfessionalTabController extends GetxController {
  final currentIndex = 0.obs;
  void goTo(int index) => currentIndex.value = index;

  // Named destinations (match the bottom-nav order / labels:
  // Home · Find · Trips · Feeds · Jobs).
  static const home = 0;
  static const find = 1;
  static const trips = 2;
  static const feeds = 3;
  static const jobs = 4;
}
