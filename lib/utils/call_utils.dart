import 'package:url_launcher/url_launcher.dart';
import 'app_logger.dart';

class CallUtils {
  static Future<void> makeCall(String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      AppLogger.e("Cannot make call: Phone number is empty");
      return;
    }

    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);

    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
        AppLogger.i("Launching call to: $phoneNumber");
      } else {
        AppLogger.e("Could not launch call to: $phoneNumber");
      }
    } catch (e) {
      AppLogger.e("Error launching call: $e");
    }
  }
}
