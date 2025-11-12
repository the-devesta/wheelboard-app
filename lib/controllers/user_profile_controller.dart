import 'dart:convert';
import 'package:get/get.dart';
import '../apihelperclass/api_helper.dart';
import '../models/user_profile_model.dart';
import '../utils/constants.dart';
import '../services/auth_service.dart';
import '../widgets/custom_snackbar.dart';

class UserProfileController extends GetxController {
  final Rx<UserProfileModel?> userProfile = Rx<UserProfileModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  /// Fetch user profile by userId
  Future<bool> fetchUserProfile(String userId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      print("==================================");
      print("📡 Fetching User Profile");
      print("👉 UserId: $userId");
      print("==================================");

      // Get auth token
      final authService = AuthService.to;
      final token = authService.currentToken;
      
      // Build endpoint URL
      final endpoint = API.userProfile.replaceAll('{userId}', userId);
      
      // Make API call
      final response = await HttpHelper.getData(
        endpoint: endpoint,
        headers: {
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
      );

      print("📥 Response Status: ${response.statusCode}");
      print("📥 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        userProfile.value = UserProfileModel.fromJson(data);
        
        print("✅ Profile loaded successfully");
        print("👉 User Type: ${userProfile.value?.userType}");
        print("👉 Display Name: ${userProfile.value?.displayName}");
        print("==================================");
        
        return true;
      } else {
        final errorMsg = "Failed to load profile: ${response.statusCode}";
        errorMessage.value = errorMsg;
        print("❌ $errorMsg");
        SnackBarHelper.error("Failed to load profile");
        return false;
      }
    } catch (e) {
      final errorMsg = "Error loading profile: ${e.toString()}";
      errorMessage.value = errorMsg;
      print("❌ $errorMsg");
      SnackBarHelper.error("Error loading profile");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch current logged-in user's profile
  Future<bool> fetchCurrentUserProfile() async {
    final authService = AuthService.to;
    final userId = authService.currentUserId;
    
    if (userId.isEmpty) {
      errorMessage.value = "User not logged in";
      SnackBarHelper.error("Please login to view profile");
      return false;
    }
    
    return await fetchUserProfile(userId);
  }

  /// Refresh profile data
  Future<void> refreshProfile() async {
    if (userProfile.value != null) {
      await fetchUserProfile(userProfile.value!.userId);
    }
  }

  /// Clear profile data
  void clearProfile() {
    userProfile.value = null;
    errorMessage.value = '';
  }
}

