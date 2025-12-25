import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wheelboard/apihelperclass/api_helper.dart';
import 'package:wheelboard/models/Professional/referral_model.dart';
import 'package:wheelboard/services/auth_service.dart';
import 'package:wheelboard/utils/constants.dart';
import 'package:wheelboard/utils/error_handler.dart';

class AddReferralController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  RxBool isLoading = false.obs;

  RxList<ReferralModel> referrals = <ReferralModel>[].obs;

  @override
  void onInit() {
    getReferrals();
    super.onInit();
  }

  Future<void> getReferrals() async {
    try {
      isLoading.value = true;

      final userId = _authService.userId;

      final response = await HttpHelper.getData(
        endpoint: '${API.getReferralList}$userId',
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        referrals.assignAll(
          data.map((e) => ReferralModel.fromJson(e)).toList(),
        );
      } else {}
    } catch (e) {
      debugPrint('Error==>> ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}
