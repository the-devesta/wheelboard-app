import 'dart:io';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/service_provider_signup.dart';
import '../apihelperclass/api_helper.dart';
import '../utils/constants.dart';
import '../utils/navigation_helper.dart';
import '../widgets/custom_snackbar.dart';

class ServiceProviderController extends GetxController {
  var isLoading = false.obs;

  Future<void> completeServiceProvider(ServiceProviderModel model) async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;

      final fields = model.toJsonFields();
      final files = <File>[];

      if (model.getBusinessLogo() != null) {
        files.add(model.getBusinessLogo()!);
      }

      final streamedResponse = await HttpHelper.uploadMultipart(
        endpoint: API.completeServiceProvider,
        fields: fields,
        files: files,
        fieldKey: "BusinessLogo",
        headers: {'Accept': 'application/json'},
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        SnackBarHelper.success("Profile completed successfully!");
        await Future.delayed(const Duration(milliseconds: 1500));
        NavigationHelper.navigateToMainWrapper();
        return;
      }

      String errorMessage = "Profile completion failed";
      try {
        final body = json.decode(response.body);
        errorMessage = body['message'] ?? body['error'] ?? errorMessage;
      } catch (_) {
        if (response.body.isNotEmpty) {
          errorMessage = response.body;
        }
      }

      SnackBarHelper.error(errorMessage);
    } catch (e) {
      SnackBarHelper.error("Something went wrong: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }
}
