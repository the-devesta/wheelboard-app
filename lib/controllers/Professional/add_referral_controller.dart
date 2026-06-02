import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:wheelboard/core/network/api_client.dart';
import 'package:wheelboard/core/network/api_endpoints.dart';
import 'package:wheelboard/core/network/api_exception.dart';
import 'package:wheelboard/models/Professional/referral_model.dart';
import 'package:wheelboard/core/auth/auth_service.dart';
import '../../utils/app_logger.dart';

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

      final userId = _authService.currentUserId;

      final data = await ApiClient.instance.get<List<dynamic>>(
        ApiEndpoints.users.referralsByUser(userId),
      );

      referrals.assignAll(
        data.map((e) => ReferralModel.fromJson(e)).toList(),
      );
    } on DioException catch (e) {
      final msg = e.error is ApiException ? (e.error as ApiException).message : 'Failed to load referrals';
      AppLogger.d('Error==>> $msg');
    } catch (e) {
      AppLogger.d('Error==>> ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}
