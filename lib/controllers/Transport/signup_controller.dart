import 'package:get/get.dart';

import '../../core/auth/auth_service.dart' as core;
import '../../core/auth/user_role.dart';
import '../../models/company_signupmodel.dart';
import '../../utils/app_logger.dart';
import '../../widgets/custom_snackbar.dart';

/// Signup controller — now uses the centralized [core.AuthService]
/// which calls: POST /api/auth/register (same as wheelboard-fe authAPI.register())
///
/// The backend RegisterDto expects:
///   { email, password, role, phoneNumber?, profile?, identityType?, identityNumber? }
class SignupController extends GetxController {
  var isLoading = false.obs;
  var obscurePassword = true.obs;
  var userId = RxnString();

  core.AuthService get _auth => core.AuthService.to;

  /// Register a company (Transport or Service Provider).
  /// Matches: POST /api/auth/register
  Future<bool> registerCompany(CompanySignUpModel model) async {
    if (isLoading.value) {
      AppLogger.d(
        '⚠️ registerCompany called while a request is already in progress',
      );
      SnackBarHelper.error('Registration already in progress. Please wait.');
      return false;
    }

    isLoading.value = true;
    try {
      AppLogger.d('================================');
      AppLogger.d('📤 Signup Request (new API):');
      AppLogger.d('📱 Mobile: ${model.mobileNo}');
      AppLogger.d('🏢 Company: ${model.companyName}');
      AppLogger.d('📧 Email: ${model.email}');
      AppLogger.d('📂 Category: ${model.businessCategory}');
      AppLogger.d('================================');

      // Map businessCategory to backend UserRole
      final String role;
      if (model.businessCategory.toLowerCase() == 'service provider') {
        role = UserRole.business.value; // 'business'
      } else {
        role = UserRole.company.value; // 'company' (Transport)
      }

      // Build profile matching backend CompanyProfile / BusinessProfile
      final Map<String, dynamic> profile;
      if (role == UserRole.business.value) {
        // Service Provider profile
        profile = {
          'businessName': model.companyName,
          'ownerName': model.contactPerson.isNotEmpty ? model.contactPerson : model.companyName,
          'phoneNumber': model.mobileNo,
          'businessCategory': 'Service Provider',
        };
      } else {
        // Transport company profile
        profile = {
          'companyName': model.companyName,
          'contactPerson': model.contactPerson.isNotEmpty ? model.contactPerson : model.companyName,
          'phoneNumber': model.mobileNo,
          'businessCategory': 'Transport',
        };
      }

      final response = await _auth.register(
        email: model.email.isNotEmpty
            ? model.email
            : '${model.mobileNo}@wheelboard.in', // Email required by backend
        password: model.password,
        role: role,
        phoneNumber: model.mobileNo,
        profile: profile,
      );

      userId.value = response.user.id;
      AppLogger.d('✅ Registration successful: userId=${response.user.id}');
      return true;
    } catch (e) {
      AppLogger.e('❌ Registration failed', error: e);
      SnackBarHelper.error(core.AuthService.extractError(e));
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
