import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:wheelboard/apihelperclass/api_helper.dart';
import 'package:wheelboard/models/dashboard_model.dart';
import 'package:wheelboard/models/myassign_sevice_list.dart';
import 'package:wheelboard/services/auth_service.dart';
import 'package:wheelboard/utils/app_logger.dart';
import 'package:wheelboard/utils/constants.dart';
import 'package:wheelboard/utils/error_handler.dart';
import 'package:wheelboard/widgets/custom_snackbar.dart';

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

  RxInt expandedIndex = (-1).obs;

  void toggleExpand(int index) {
    expandedIndex.value = expandedIndex.value == index ? -1 : index;
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
    final q = searchCtrl.text.toLowerCase().trim();

    if (q.isEmpty) {
      filteredServices.assignAll(allServices);
    } else {
      filteredServices.assignAll(
        allServices.where((service) {
          return service.serviceTitle.toLowerCase().contains(q) ||
              service.description.toLowerCase().contains(q);
        }).toList(),
      );
    }
  }

  Future<bool> deleteService(String assignmentId) async {
    try {
      isLoading.value = true;
      final endpoint = '${API.deleteService}/$assignmentId/delete';

      final response = await HttpHelper.postData(
        endpoint: endpoint,
        data: {},
        headers: {'Accept': '*/*', 'Content-Type': 'application/json'},
      );

      AppLogger.d("🗑️ Delete response status: ${response.statusCode}");
      AppLogger.d("🗑️ Delete response body: ${response.body}");

      if (response.statusCode == 200) {
        SnackBarHelper.success("Service deleted successfully!");
        getServices();
        return true;
      }

      final errorMessage = ErrorHandler.parseError(
        response.body,
        statusCode: response.statusCode,
      );

      SnackBarHelper.error(errorMessage);
      return false;
    } catch (e) {
      AppLogger.d("❌ Error deleting service: $e");
      final errorMessage = ErrorHandler.handleNetworkError(e);
      SnackBarHelper.error(errorMessage);
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
