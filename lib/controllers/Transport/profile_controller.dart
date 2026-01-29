import 'package:get/get.dart';
import 'package:country_picker/country_picker.dart';

class ProfileController extends GetxController {
  var selectedDialCode = '+91'.obs; // Initial value
  var selectedCountryCode = 'IN'.obs; // Optional

  void updateCountry(Country country) {
    selectedDialCode.value = '+${country.phoneCode}';
    selectedCountryCode.value = country.countryCode;
  }
}
