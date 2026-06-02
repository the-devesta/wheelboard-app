import 'package:get/get.dart';
import '../../core/auth/auth_service.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../models/user_profile_model.dart';
import '../../widgets/custom_snackbar.dart';
import '../../utils/app_logger.dart';

class UserProfileController extends GetxController {
  final Rx<UserProfileModel?> userProfile = Rx<UserProfileModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Preference Toggles (Local State)
  var smsNotifications = true.obs;
  var emailNotifications = false.obs;
  var whatsappNotifications = true.obs;

  void toggleSmsNotifications(bool value) => smsNotifications.value = value;
  void toggleEmailNotifications(bool value) => emailNotifications.value = value;
  void toggleWhatsappNotifications(bool value) =>
      whatsappNotifications.value = value;

  /// Fetch another user's public profile — calls GET /users/:id/public-profile.
  /// Matches wheelboard-fe's userAPI.getUserProfile().
  Future<bool> fetchUserProfile(String userId) async {
    final auth = AuthService.to;

    // For the current user's own profile, use the auth endpoint.
    if (userId == auth.currentUserId) {
      return fetchCurrentUserProfile();
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final data = await ApiClient.instance.get<Map<String, dynamic>>(
        ApiEndpoints.users.publicProfile(userId),
      );

      userProfile.value = UserProfileModel.fromPublicProfile(data);
      AppLogger.d("✅ Public profile loaded for $userId");
      return true;
    } catch (e) {
      final msg = "Failed to load profile: ${e.toString()}";
      errorMessage.value = msg;
      AppLogger.e("❌ $msg", error: e);
      SnackBarHelper.error("Failed to load profile");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch the current logged-in user's profile — calls GET /auth/profile.
  /// Matches wheelboard-fe's authAPI.getProfile().
  Future<bool> fetchCurrentUserProfile() async {
    final auth = AuthService.to;

    if (auth.currentUserId.isEmpty) {
      errorMessage.value = "User not logged in";
      SnackBarHelper.error("Please login to view profile");
      return false;
    }

    // Optimistically populate from cached user so UI doesn't flash empty.
    if (auth.currentUser.value != null) {
      userProfile.value = UserProfileModel.fromAppUser(auth.currentUser.value!);
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Refresh from backend (same as wheelboard-fe authAPI.getProfile())
      final user = await auth.getProfile();
      userProfile.value = UserProfileModel.fromAppUser(user);

      AppLogger.d("✅ Profile loaded: ${user.role.value} | ${user.displayName}");
      AppLogger.d("👉 KYC: ${user.isKYCCompleted}");
      return true;
    } catch (e) {
      final msg = "Failed to load profile: ${e.toString()}";
      errorMessage.value = msg;
      AppLogger.e("❌ $msg", error: e);
      // Keep cached value if available
      if (userProfile.value == null) {
        SnackBarHelper.error("Failed to load profile");
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh profile data.
  Future<void> refreshProfile() async {
    await fetchCurrentUserProfile();
  }

  /// Sync KYC status from the live /kyc/my-kyc endpoint.
  /// Mirrors the 30-second polling that professional/company pages do in
  /// wheelboard-fe. Call once per profile page open; repeat if still pending.
  Future<void> syncKycStatus() async {
    try {
      final data = await ApiClient.instance.get<Map<String, dynamic>>(
        ApiEndpoints.kyc.myKyc,
      );
      // overallStatus is the authoritative field from the KYC service
      final overallStatus =
          data['overallStatus']?.toString().toLowerCase() ?? '';
      if (overallStatus == 'verified') {
        await AuthService.to.updateKYCStatus(true);
        // Rebuild UserProfileModel so the UI reflects the new KYC state
        final user = AuthService.to.currentUser.value;
        if (user != null) {
          userProfile.value = UserProfileModel.fromAppUser(user);
        }
        AppLogger.d('✅ KYC synced from live API → verified');
      }
    } catch (e) {
      // Non-fatal: profile already shows the profile-level KYC flags
      AppLogger.d('ℹ️ KYC live-sync skipped (non-fatal): $e');
    }
  }

  /// Clear profile data.
  void clearProfile() {
    userProfile.value = null;
    errorMessage.value = '';
  }
}
