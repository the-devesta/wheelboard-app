import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wheelboard/apihelperclass/api_helper.dart';
import 'package:wheelboard/controllers/Professional/add_referral_controller.dart';
import 'package:wheelboard/services/auth_service.dart';
import 'package:wheelboard/utils/constants.dart';
import 'package:wheelboard/utils/error_handler.dart';
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

    debugPrint('hereeeee111====>>');
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
        "role": selectedRole.toString(),
        "location": locationController.text.trim().isEmpty
            ? ""
            : locationController.text.trim(),
        "notifyOnAcceptance": notify.value,
        "referralStatus": "pending",
        "referralDate": DateTime.now().toIso8601String(),
      };

      debugPrint('data===>>>${requestData}');
      AppLogger.d(requestData.toString());

      debugPrint('hereeeee22====>>');

      final response = await HttpHelper.postData(
        endpoint: API.saveReferal,
        data: requestData,
      );

      debugPrint('Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        addReferralController.getReferrals();

        debugPrint('hereeeee33====>>');

        try {
          final responseData = jsonDecode(response.body);
          if (responseData['success'] == true) {
            SnackBarHelper.success('Referral added successfully');

            Future.delayed(Duration(seconds: 2), () {
              debugPrint('Going back...');
              Navigator.of(context).pop();
            });
            return;
          }
        } catch (e) {
          SnackBarHelper.success('Referral added successfully');
          Future.delayed(Duration(seconds: 2), () {
            Navigator.of(context).pop();
          });
          return;
        }
      } else {
        debugPrint('hereeeee44====>>');
        SnackBarHelper.error('Server error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('hereeeee44====>> Error: $e');
      AppLogger.d(e.toString());
      final errorMessage = ErrorHandler.handleNetworkError(e);
      SnackBarHelper.error(errorMessage);
    } finally {
      debugPrint('hereeeee55====>>');
      isLoading.value = false;
    }
  }
}
