import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:wheelboard/core/network/api_client.dart';
import 'package:wheelboard/core/network/api_endpoints.dart';
import 'package:wheelboard/core/network/api_exception.dart';
import 'package:wheelboard/controllers/Professional/add_referral_controller.dart';
import 'package:wheelboard/core/auth/auth_service.dart';
import 'package:wheelboard/widgets/custom_snackbar.dart';
import '../../utils/app_logger.dart';

class NewReferralController extends GetxController {
  final AddReferralController addReferralController =
      Get.find<AddReferralController>();
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final locationController = TextEditingController();

  final notify = false.obs;
  final selectedRole = RxnString();
  RxBool isLoading = false.obs;
  // Get userId from AuthService
  final authService = Get.find<AuthService>();

  final roles = [
    {"title": "Driver", "icon": Icons.local_shipping_outlined},
    {"title": "Tyre Fitter", "icon": Icons.build_outlined},
    {"title": "Mechanic", "icon": Icons.settings_outlined},
    {"title": "Consulting Agent", "icon": Icons.person_outline},
  ];

  bool get isFormValid =>
      nameController.text.isNotEmpty &&
      mobileController.text.isNotEmpty &&
      selectedRole.value != null;

  @override
  void onInit() {
    super.onInit();
    nameController.addListener(update);
    mobileController.addListener(update);
    emailController.addListener(update);
    locationController.addListener(update);
  }

  void selectRole(String role) {
    selectedRole.value = role;
    update();
  }

  void toggleNotify(bool value) {
    notify.value = value;
  }

  @override
  void onClose() {
    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    locationController.dispose();
    super.onClose();
  }

  Future<void> saveReferal(BuildContext context) async {
    final userId = authService.currentUserId;

    AppLogger.d('User ID: $userId');

    if (!isFormValid) {
      SnackBarHelper.error('Please fill required input');
      return;
    }

    isLoading.value = true;

    try {
      final Map<String, dynamic> requestData = {
        "referralId": userId,
        "createdBy": userId,
        "partnerId": 0,
        "userId": userId,
        "fullName": nameController.text.trim(),
        "mobileNumber": mobileController.text.trim(),
        "email": emailController.text.trim().isEmpty
            ? ""
            : emailController.text.trim(),
        "role": selectedRole.value ?? '',
        "location": locationController.text.trim().isEmpty
            ? ""
            : locationController.text.trim(),
        "notifyOnAcceptance": notify.value,
        "referralStatus": "pending",
        "referralDate": DateTime.now().toIso8601String(),
      };

      AppLogger.d(requestData.toString());

      final data = await ApiClient.instance.post<Map<String, dynamic>>(
        ApiEndpoints.users.saveReferral,
        data: requestData,
      );

      addReferralController.getReferrals();

      SnackBarHelper.success(data['message'] ?? 'Referral added successfully');

      Future.delayed(const Duration(seconds: 2), () {
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      });
    } on DioException catch (e) {
      final msg = e.error is ApiException ? (e.error as ApiException).message : 'Failed to add referral';
      SnackBarHelper.error(msg);
      AppLogger.d(e.toString());
    } catch (e) {
      AppLogger.d(e.toString());
      SnackBarHelper.error("Something went wrong");
    } finally {
      isLoading.value = false;
    }
  }
}
