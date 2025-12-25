import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../apihelperclass/api_helper.dart';
import '../utils/constants.dart';
import '../models/add_drivermodel.dart';
import '../widgets/custom_snackbar.dart';
import '../utils/app_logger.dart';

class AddDriverController extends GetxController {
  var isLoading = false.obs;

  /// Parse error message from backend response
  String _parseErrorMessage(String responseBody, String defaultMessage) {
    try {
      final data = json.decode(responseBody);
      // Try common error message fields
      if (data is Map) {
        if (data.containsKey('message') && data['message'] != null) {
          return data['message'].toString();
        }
        if (data.containsKey('Message') && data['Message'] != null) {
          return data['Message'].toString();
        }
        if (data.containsKey('error') && data['error'] != null) {
          return data['error'].toString();
        }
        if (data.containsKey('Error') && data['Error'] != null) {
          return data['Error'].toString();
        }
        if (data.containsKey('title') && data['title'] != null) {
          return data['title'].toString();
        }
        if (data.containsKey('errors') && data['errors'] != null) {
          // Handle validation errors
          final errors = data['errors'];
          if (errors is Map && errors.isNotEmpty) {
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              return firstError.first.toString();
            }
          }
        }
      }
      // If response is plain string
      if (responseBody.isNotEmpty && !responseBody.startsWith('{')) {
        return responseBody;
      }
    } catch (e) {
      AppLogger.d("Error parsing response: $e");
    }
    return defaultMessage;
  }

  Future<bool> addDriver(DriverModel driverModel, String token) async {
    try {
      isLoading.value = true;

      final fields = driverModel.toJsonFields();
      final File? imageFile = driverModel.image;

      final streamedResponse =
          await HttpHelper.uploadMultipart(
            endpoint: API.addDriver,
            fields: fields,
            files: imageFile != null ? [imageFile] : [],
            fieldKey: "Image",
            headers: {"Authorization": "Bearer $token"},
          ).timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception("Request timeout. Please try again.");
            },
          );

      final response = await http.Response.fromStream(streamedResponse);

      AppLogger.d(
        "👤 Add Driver Response: ${response.statusCode} - ${response.body}",
      );

      if (response.statusCode == 200) {
        SnackBarHelper.success("Driver added successfully");
        return true;
      } else {
        // Show actual error message from backend
        final errorMessage = _parseErrorMessage(
          response.body,
          "Unable to add driver. Please try again.",
        );

        SnackBarHelper.error(errorMessage);
        return false;
      }
    } catch (e) {
      AppLogger.d("👤 Add Driver Exception: $e");
      SnackBarHelper.error(
        "Unable to connect to server. Please check your internet connection.",
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateDriver(DriverModel driverModel, String token) async {
    try {
      isLoading.value = true;

      final fields = driverModel.toJsonFields();
      final File? imageFile = driverModel.image;

      final streamedResponse =
          await HttpHelper.uploadMultipart(
            endpoint: API.updateDriver,
            fields: fields,
            files: imageFile != null ? [imageFile] : [],
            fieldKey: "Image",
            headers: {"Authorization": "Bearer $token"},
          ).timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception("Request timeout. Please try again.");
            },
          );

      final response = await http.Response.fromStream(streamedResponse);

      AppLogger.d(
        "👤 Update Driver Response: ${response.statusCode} - ${response.body}",
      );

      if (response.statusCode == 200) {
        SnackBarHelper.success("Driver updated successfully");
        return true;
      } else {
        // Show actual error message from backend
        final errorMessage = _parseErrorMessage(
          response.body,
          "Unable to update driver. Please try again.",
        );

        SnackBarHelper.error(errorMessage);
        return false;
      }
    } catch (e) {
      AppLogger.d("👤 Update Driver Exception: $e");
      SnackBarHelper.error(
        "Unable to connect to server. Please check your internet connection.",
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
