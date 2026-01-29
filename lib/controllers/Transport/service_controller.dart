import 'dart:convert';

import 'package:get/get.dart';

import '../../apihelperclass/api_helper.dart';
import '../../models/service_model.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_snackbar.dart';

class ServiceController extends GetxController {
  final isLoading = false.obs;
  final isDetailLoading = false.obs;
  final isAssigning = false.obs;
  final services = <ServiceModel>[].obs;
  final selectedService = Rxn<ServiceModel>();
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchServices();
  }

  Future<void> fetchServices() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await HttpHelper.getData(
        endpoint: API.serviceList,
        headers: const {'Accept': '*/*'},
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> data = body['data'] as List<dynamic>? ?? [];

        services.assignAll(
          data.map((e) => ServiceModel.fromJson(e as Map<String, dynamic>)),
        );
      } else {
        errorMessage.value = 'Failed to load services (${response.statusCode})';
        SnackBarHelper.error(errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = 'Failed to load services: ${e.toString()}';
      SnackBarHelper.error(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchServiceDetail(String serviceId) async {
    try {
      isDetailLoading.value = true;
      errorMessage.value = '';

      final response = await HttpHelper.getData(
        endpoint: '${API.serviceDetail}$serviceId',
        headers: const {'Accept': '*/*'},
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'];
        if (data is Map<String, dynamic>) {
          final detail = ServiceModel.fromJson(data);

          // Merge detail into existing list item if present
          final index = services.indexWhere(
            (element) => element.serviceId == serviceId,
          );
          if (index != -1) {
            final updated = services[index].copyWith(detail);
            services[index] = updated;
            selectedService.value = updated;
          } else {
            selectedService.value = detail;
          }
        } else {
          errorMessage.value = 'Invalid detail response';
          SnackBarHelper.error(errorMessage.value);
        }
      } else {
        errorMessage.value =
            'Failed to load service detail (${response.statusCode})';
        SnackBarHelper.error(errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = 'Failed to load service detail: ${e.toString()}';
      SnackBarHelper.error(errorMessage.value);
    } finally {
      isDetailLoading.value = false;
    }
  }

  Future<bool> assignService({
    required String serviceId,
    required String assignedToUserId,
    required String vehicleNumber,
    required DateTime scheduledDate,
    required String scheduledTime,
    required String description,
    String? serviceTitle,
  }) async {
    try {
      isAssigning.value = true;
      errorMessage.value = '';

      final payload = <String, dynamic>{
        'serviceId': serviceId,
        'assignedToUserId': assignedToUserId,
        'vehicleNumber': vehicleNumber,
        'scheduledDate': scheduledDate.toIso8601String(),
        'scheduledTime': scheduledTime,
        'description': description,
      };

      if (serviceTitle != null && serviceTitle.isNotEmpty) {
        payload['serviceTitle'] = serviceTitle;
      }

      final response = await HttpHelper.postData(
        endpoint: API.assignService,
        data: payload,
        headers: const {'Accept': '*/*', 'Content-Type': 'application/json'},
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = response.body.isNotEmpty
            ? jsonDecode(response.body) as Map<String, dynamic>?
            : null;
        final successValue = body?['success'];
        final responseSuccess = successValue is bool ? successValue : true;

        if (responseSuccess) {
          final message =
              body?['message'] as String? ?? 'Service assigned successfully.';
          SnackBarHelper.success(message);
          return true;
        } else {
          final message =
              body?['message'] as String? ?? 'Failed to assign service.';
          errorMessage.value = message;
          SnackBarHelper.error(message);
        }
      } else {
        errorMessage.value =
            'Failed to assign service (${response.statusCode})';
        SnackBarHelper.error(errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = 'Failed to assign service: ${e.toString()}';
      SnackBarHelper.error(errorMessage.value);
    } finally {
      isAssigning.value = false;
    }
    return false;
  }

  ServiceModel? getServiceById(String serviceId) {
    try {
      return services.firstWhere((element) => element.serviceId == serviceId);
    } catch (_) {
      return null;
    }
  }
}
