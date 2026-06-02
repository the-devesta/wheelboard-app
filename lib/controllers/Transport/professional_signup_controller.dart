import 'package:get/get.dart';

import '../../core/auth/auth_service.dart' as core;
import '../../core/auth/user_role.dart';
import '../../utils/app_logger.dart';
import '../../widgets/custom_snackbar.dart';

class ProfessionalController extends GetxController {
  var isLoading = false.obs;
  var obscurePassword = true.obs;

  core.AuthService get _auth => core.AuthService.to;

  /// Register a professional.
  /// Matches: POST /api/auth/register (same as wheelboard-fe)
  /// Payload: { email, password, role: 'professional', phoneNumber, profile: { firstName, lastName, phoneNumber } }
  Future<bool> registerProfessional({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    String? professionalType,
    String? city,
  }) async {
    if (isLoading.value) return false;

    isLoading.value = true;
    try {
      final profile = <String, dynamic>{
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phone,
        if (professionalType != null && professionalType.isNotEmpty)
          'professionalType': professionalType,
        if (city != null && city.isNotEmpty) 'city': city,
      };

      AppLogger.d('📤 Professional register: email=$email, phone=$phone, type=$professionalType');

      await _auth.register(
        email: email,
        password: password,
        role: UserRole.professional.value,
        phoneNumber: phone,
        profile: profile,
      );

      SnackBarHelper.success('Registered successfully! Please log in to continue.');
      return true;
    } catch (e) {
      AppLogger.e('❌ Professional registration failed', error: e);
      SnackBarHelper.error(core.AuthService.extractError(e));
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
