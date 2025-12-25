import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wheelboard/apihelperclass/api_helper.dart';
import 'package:wheelboard/models/user_profile_model.dart';
import 'package:wheelboard/services/auth_service.dart';
import 'package:wheelboard/utils/constants.dart';
import 'package:wheelboard/utils/error_handler.dart';
import 'package:wheelboard/utils/session_manager.dart';
import 'package:wheelboard/widgets/custom_snackbar.dart';

class NewReferralController extends GetxController {
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final locationController = TextEditingController();

  final notify = false.obs;
  final selectedRole = RxnString();
  final SessionManager _sessionManager = SessionManager();
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

  Future<void> saveReferal() async {
    final userId = authService.currentUserId;

    debugPrint('User ID: $userId');
    if (!isFormValid) {
      SnackBarHelper.error('Please fill required input');
      return;
    }

    isLoading.value = true;

    // try {
    final requestData = {
      "referralId": "",
      "createdBy": "",
      "partnerId": 0,
      "userId": userId,
      "fullName": nameController.text.toString(),
      "mobileNumber": mobileController.text.toString(),
      "email": emailController.text.toString(),
      "role": selectedRole,
      "location": locationController.text.toString(),
      "notifyOnAcceptance": notify,
      "referralStatus": "",
    };

    debugPrint(requestData.toString());

    final response = await HttpHelper.postData(
      endpoint: API.saveReferal,
      data: requestData,
    );
    debugPrint('${response} data===>>');
    if (response.statusCode == 200) {
      SnackBarHelper.success('Referral added successfully');
    }
    // } catch (e) {
    //   debugPrint(e.toString());
    //   // final errorMessage = ErrorHandler.handleNetworkError(e);
    //   // SnackBarHelper.error(errorMessage);
    // } finally {
    //   isLoading.value = false;
    // }
  }
}
