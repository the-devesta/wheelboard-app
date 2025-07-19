// lib/controllers/register_controller.dart
import 'package:get/get.dart';

class RegisterController extends GetxController {
  var selectedType = 'Professional'.obs;

  void selectType(String type) {
    selectedType.value = type;
  }
}
