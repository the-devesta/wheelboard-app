import 'package:get/get.dart';
import 'package:flutter/material.dart';

class TripPageTabController extends GetxController {
  final RxInt currentTabIndex = 0.obs;
  TabController? tabController;

  void setTabController(TabController controller) {
    tabController = controller;
  }

  void switchToTab(int index) {
    currentTabIndex.value = index;
    if (tabController != null && tabController!.index != index) {
      tabController!.animateTo(index);
    }
  }

  void switchToUpcoming() {
    switchToTab(2);
  }
}
