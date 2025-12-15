/// KYC Helper
/// Use this to check KYC status before allowing job apply or bid submit

import 'package:get/get.dart';
import '../controllers/user_profile_controller.dart';
import '../services/auth_service.dart';
import '../widgets/custom_snackbar.dart';

class KYCHelper {
  /// Check if KYC is completed
  /// Returns true if KYC is complete, false otherwise
  static bool isKYCCompleted() {
    try {
      // ✅ First check AuthService (saved from login)
      try {
        final authService = AuthService.to;
        final kycFromAuth = authService.isUserKYCCompleted;
        print("🔐 KYC Status from AuthService: $kycFromAuth");

        // If AuthService has KYC status, use it
        if (kycFromAuth) {
          return true;
        }
      } catch (e) {
        print("⚠️ AuthService not found, checking UserProfile: $e");
      }

      // ✅ Fallback to UserProfileController
      final controller = Get.find<UserProfileController>();
      final profile = controller.userProfile.value;

      // Check if KYC is completed from profile
      final kycFromProfile = profile?.isKYCCompleted ?? false;
      print("👤 KYC Status from Profile: $kycFromProfile");
      return kycFromProfile;
    } catch (e) {
      // If controller not found, assume KYC is incomplete
      print("❌ Error checking KYC: $e");
      return false;
    }
  }

  /// Show KYC incomplete warning dialog
  static void showKYCRequiredDialog() {
    SnackBarHelper.warning(
      '⚠️ KYC Required!\n'
      'Please complete your KYC verification to apply for jobs, like jobs, or submit bids.\n\n'
      'Go to: Profile → Complete KYC',
    );
  }

  /// Check KYC and show dialog if incomplete
  /// Returns true if KYC is complete, false if incomplete
  static bool checkAndShowKYCDialog() {
    if (!isKYCCompleted()) {
      showKYCRequiredDialog();
      return false;
    }
    return true;
  }
}
