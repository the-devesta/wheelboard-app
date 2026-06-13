import 'package:get/get.dart';

import '../../core/auth/auth_service.dart' as core;
import '../../core/auth/auth_models.dart';
import '../../utils/app_logger.dart';
import '../../widgets/custom_snackbar.dart';

/// Login controller — now uses the centralized [core.AuthService]
/// which calls the same endpoints as wheelboard-fe:
///   - POST /api/auth/request-otp  { mobileNo }
///   - POST /api/auth/login/otp    { mobileNo, otp }
///   - POST /api/auth/login        { identifier, password }
class LoginController extends GetxController {
  var isLoading = false.obs;
  var isOTPSent = false.obs;
  var obscurePassword = true.obs;

  core.AuthService get _auth => core.AuthService.to;

  String _formatPhone(String phone) {
    String p = phone.trim();
    // Remove +91 or 91 prefix if present — API expects plain 10-digit number
    if (p.startsWith('+91')) {
      p = p.substring(3);
    } else if (p.startsWith('91') && p.length > 10) {
      p = p.substring(2);
    }
    return p;
  }

  void resetOTP() {
    isOTPSent.value = false;
  }

  // ── Send OTP ───────────────────────────────────────────────────────────
  // Calls: POST /api/auth/request-otp { mobileNo }

  Future<bool> sendOTP(String phone) async {
    final formattedPhone = _formatPhone(phone);
    if (formattedPhone.isEmpty) {
      SnackBarHelper.error('Please enter phone number');
      return false;
    }

    isLoading.value = true;
    try {
      final message = await _auth.requestOtp(mobileNo: formattedPhone);
      isOTPSent.value = true;
      SnackBarHelper.success(message);
      return true;
    } catch (e) {
      SnackBarHelper.error(core.AuthService.extractError(e));
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ── Login with OTP ─────────────────────────────────────────────────────
  // Calls: POST /api/auth/login/otp { mobileNo, otp }
  // Returns the full AuthResponse so the UI can read user/role/profile.

  Future<AuthResponse?> loginWithOTP(String phone, String otp) async {
    final formattedPhone = _formatPhone(phone);
    if (formattedPhone.isEmpty) {
      SnackBarHelper.error('Please enter phone number');
      return null;
    }
    if (otp.trim().isEmpty) {
      SnackBarHelper.error('Please enter OTP');
      return null;
    }

    isLoading.value = true;
    try {
      final response = await _auth.loginWithOtp(
        mobileNo: formattedPhone,
        otp: otp.trim(),
      );
      AppLogger.d('✅ OTP login successful: ${response.user.role.value}');
      return response;
    } catch (e) {
      AppLogger.e('OTP login failed after request', error: e);
      SnackBarHelper.error(core.AuthService.extractError(e));
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // ── Login with Password ────────────────────────────────────────────────
  // Calls: POST /api/auth/login { identifier, password }

  Future<AuthResponse?> login(String identifier, String password) async {
    if (identifier.trim().isEmpty) {
      SnackBarHelper.error('Please enter phone number or email');
      return null;
    }
    if (password.trim().isEmpty) {
      SnackBarHelper.error('Please enter password');
      return null;
    }

    isLoading.value = true;
    try {
      // Format phone if it looks like a phone number
      String formattedIdentifier = identifier.trim();
      if (!formattedIdentifier.contains('@')) {
        formattedIdentifier = _formatPhone(formattedIdentifier);
      }

      final response = await _auth.login(
        identifier: formattedIdentifier,
        password: password.trim(),
      );
      AppLogger.d('✅ Password login successful: ${response.user.role.value}');
      return response;
    } catch (e) {
      AppLogger.e('Password login failed after request', error: e);
      SnackBarHelper.error(core.AuthService.extractError(e));
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }
}
