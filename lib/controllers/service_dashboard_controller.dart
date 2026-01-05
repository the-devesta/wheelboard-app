import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:wheelboard/apihelperclass/api_helper.dart';
import 'package:wheelboard/models/dashboard_model.dart';
import 'package:wheelboard/models/myassign_sevice_list.dart';
import 'package:wheelboard/services/auth_service.dart';
import 'package:wheelboard/utils/constants.dart';

class ServiceDashboardController extends GetxController {
  RxBool isLoading = false.obs;

  RxList<AssignedServiceModel> allServices = <AssignedServiceModel>[].obs;
  RxList<AssignedServiceModel> filteredServices = <AssignedServiceModel>[].obs;

  final searchCtrl = TextEditingController();

  @override
  void onInit() {
    getServices();
    searchCtrl.addListener(_applySearch);
    super.onInit();
  }

  Future<void> getServices() async {
    try {
      isLoading.value = true;
      final response = await HttpHelper.getData(
        endpoint:
            '${API.getAssingServiceList}${Get.find<AuthService>().userId}',
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        debugPrint('data====>>>${response.body}');
        final List data = jsonDecode(response.body);

        allServices.assignAll(
          data.map((e) => AssignedServiceModel.fromJson(e)).toList(),
        );

        filteredServices.assignAll(allServices);
      }

      isLoading.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  void _applySearch() {
    final q = searchCtrl.text.toLowerCase();

    if (q.isEmpty) {
      filteredServices.assignAll(allServices);
    } else {
      // filteredServices.assignAll(
      //   allServices.where((s) =>
      //       s.serviceTitle!.toLowerCase().contains(q) ||
      //       s.vehicleNumber.toLowerCase().contains(q)),
      // );
    }
  }
}
