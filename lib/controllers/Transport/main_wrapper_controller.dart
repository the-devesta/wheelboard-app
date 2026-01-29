import 'package:get/get.dart';

class MainWrapperController extends GetxController {
  final RxInt currentTabIndex = 0.obs;

  void switchToTab(int index) {
    currentTabIndex.value = index;
  }

  void switchToTripsTab() {
    switchToTab(2); // Trips tab is at index 2
  }
}
