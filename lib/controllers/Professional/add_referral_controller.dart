import 'package:get/get.dart';

class AddReferralController extends GetxController {
  final referrals = [
    {
      "name": "Ajay Verma",
      "role": "Driver",
      "date": "22 May 2025",
      "status": "Accepted",
      "points": "+25 PTS",
      "isAccepted": true,
    },
    {
      "name": "Sonia Malik",
      "role": "Tyre Fitter",
      "date": "20 May 2025",
      "status": "Pending",
      "points": "",
      "isAccepted": false,
    },
  ];

  @override
  void onInit() {
    super.onInit();
  }
}
