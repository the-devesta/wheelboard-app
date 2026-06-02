import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../models/service_model.dart';
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

      // Backend GET /services returns a plain array directly
      final response = await ApiClient.instance.get<dynamic>(
        ApiEndpoints.services.list,
      );

      List<dynamic> data = [];
      if (response is List) {
        data = response;
      } else if (response is Map) {
        data = (response['data'] as List<dynamic>?) ?? (response['services'] as List<dynamic>?) ?? [];
      }

      services.assignAll(
        data.map((e) => ServiceModel.fromJson(e as Map<String, dynamic>)),
      );
    } on DioException catch (e) {
      final msg = e.error is ApiException ? (e.error as ApiException).message : 'Failed to load services';
      errorMessage.value = msg;
      SnackBarHelper.error(msg);
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

      final response = await ApiClient.instance.get<dynamic>(
        ApiEndpoints.services.details(serviceId),
      );

      // Backend returns the service object directly, not wrapped in {data: {}}
      final raw = response is Map && response.containsKey('data') ? response['data'] : response;
      if (raw is Map<String, dynamic>) {
        final detail = ServiceModel.fromJson(raw);

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
    } on DioException catch (e) {
      final msg = e.error is ApiException ? (e.error as ApiException).message : 'Failed to load service detail';
      errorMessage.value = msg;
      SnackBarHelper.error(msg);
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

      final response = await ApiClient.instance.post<Map<String, dynamic>>(
        ApiEndpoints.services.createBooking,
        data: payload,
      );

      final successValue = response['success'];
      final responseSuccess = successValue is bool ? successValue : true;

      if (responseSuccess) {
        final message = response['message'] as String? ?? 'Service assigned successfully.';
        SnackBarHelper.success(message);
        return true;
      } else {
        final message = response['message'] as String? ?? 'Failed to assign service.';
        errorMessage.value = message;
        SnackBarHelper.error(message);
      }
    } on DioException catch (e) {
      final msg = e.error is ApiException ? (e.error as ApiException).message : 'Failed to assign service';
      errorMessage.value = msg;
      SnackBarHelper.error(msg);
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
