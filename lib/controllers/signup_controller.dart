import 'package:get/get.dart';

class SignupController extends GetxController {
  var selectedType = 'Professional'.obs;

  void selectType(String type) {
    selectedType.value = type;
  }
}
