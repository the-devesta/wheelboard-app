import 'package:get/get.dart';

import '../../core/auth/auth_service.dart';
import '../../core/auth/user_role.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../utils/app_logger.dart';
import '../../widgets/custom_snackbar.dart';

/// Registration controller for the **Service Provider (Business)** persona.
///
/// Mirrors the wheelboard-fe web flow 1:1 — same endpoints, same payloads:
///   1. [register]        → POST /api/auth/register   (role `business`)
///        web: `src/app/register/business/page.tsx` → `authRegister(...)`
///   2. [completeProfile] → PUT  /api/users/profile   ({ profile })
///        web: `src/app/business/complete-profile/page.tsx` → `userAPI.updateProfile(...)`
///
/// The account step delegates to the shared [AuthService.register]; the profile
/// step posts the exact same `profile` object the web app sends so the data
/// structure is identical across platforms.
class SpRegisterController extends GetxController {
  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final obscureConfirm = true.obs;

  AuthService get _auth => AuthService.to;

  /// Step 1 — create the account.
  ///
  /// Same payload as the web `authRegister({ email, phoneNumber, password,
  /// role: BUSINESS, profile: { businessName, ownerName, phoneNumber,
  /// businessCategory } })` call on `/register/business`.
  Future<bool> register({
    required String businessName,
    required String ownerName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    if (isLoading.value) return false;
    isLoading.value = true;
    try {
      await _auth.register(
        email: email,
        password: password,
        role: UserRole.business.value, // 'business'
        phoneNumber: phoneNumber,
        profile: {
          'businessName': businessName,
          'ownerName': ownerName,
          'phoneNumber': phoneNumber,
          'businessCategory': 'Service Provider',
        },
      );
      AppLogger.d('✅ Service Provider account created: ${_auth.userId}');
      return true;
    } catch (e) {
      AppLogger.e('❌ Service Provider registration failed', error: e);
      SnackBarHelper.error(AuthService.extractError(e));
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Step 2 — submit the business profile.
  ///
  /// Sends the exact `profile` object the web `complete-profile` page builds,
  /// via `PUT /users/profile` (the same endpoint as `userAPI.updateProfile`).
  /// The cached user is refreshed afterwards so route guards and the dashboard
  /// immediately see the completed profile.
  Future<bool> completeProfile(Map<String, dynamic> profile) async {
    if (isLoading.value) return false;
    isLoading.value = true;
    try {
      await ApiClient.instance.put<Map<String, dynamic>>(
        ApiEndpoints.users.updateProfile, // PUT /users/profile
        data: {'profile': profile},
      );
      await _auth.getProfile();
      AppLogger.d('✅ Service Provider profile completed');
      return true;
    } catch (e) {
      AppLogger.e('❌ Service Provider profile update failed', error: e);
      SnackBarHelper.error(AuthService.extractError(e));
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Upload / replace the profile picture (business logo).
  ///
  /// 1:1 with the web `userAPI.updateProfile(profile, profileImage, email)` →
  /// `PUT /users/profile { profile, profileImage, email }` where [profileImage]
  /// is a base64 data-URL. The backend mirrors it to logo/profileImage/avatar,
  /// so no multipart endpoint is needed (matches the web base64 path).
  Future<bool> updateProfilePhoto(String base64DataUrl) async {
    if (isLoading.value) return false;
    isLoading.value = true;
    try {
      final user = _auth.user;
      await ApiClient.instance.put<Map<String, dynamic>>(
        ApiEndpoints.users.updateProfile,
        data: {
          'profile': {...?user?.profile},
          'profileImage': base64DataUrl,
          if ((user?.email ?? '').isNotEmpty) 'email': user!.email,
        },
      );
      await _auth.getProfile();
      AppLogger.d('✅ Service Provider profile photo updated');
      return true;
    } catch (e) {
      AppLogger.e('❌ Profile photo update failed', error: e);
      SnackBarHelper.error(AuthService.extractError(e));
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
