import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart'; // import the controller
import 'package:wheelboard/CommonWidget/app_textfield.dart';
import '../constants/apps_colors.dart';
import 'profession_login.dart';
import 'package:country_picker/country_picker.dart';

class MyprofileScreen extends StatelessWidget {
  MyprofileScreen({super.key});
  final ProfileController profileController = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: const Text("Complete Your Profile"),
        actions: [
          IconButton(onPressed: () => Get.back(), icon: Icon(Icons.close)),
        ],
      ),
      body: Container(
        width: double.infinity,
        color: AppColors.primary,
        child: Container(
          margin: EdgeInsets.all(20),
          color: AppColors.white,
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            //padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  child: Icon(Icons.person, size: 40),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Company Name", style: TextStyle(fontSize: 16)),
                ),
                SizedBox(height: 5),
                AppTextField(hintText: 'Enter company name'),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("First Name"),
                          SizedBox(height: 5),
                          AppTextField(hintText: "First Name"),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Last Name"),
                          SizedBox(height: 5),
                          AppTextField(hintText: "Last Name"),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Email", style: TextStyle(fontSize: 16)),
                ),
                SizedBox(height: 5),
                AppTextField(hintText: 'Enter your email'),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Phone number", style: TextStyle(fontSize: 16)),
                ),
                SizedBox(height: 5),
                AppTextField(
                  hintText: "Enter your number",
                  keyboardType: TextInputType.phone,
                  prefixIcon: GestureDetector(
                    onTap: () {
                      showCountryPicker(
                        context: context,
                        showPhoneCode: true,
                        onSelect: (Country country) {
                          profileController.updateCountry(country);
                        },
                      );
                    },
                    child: Obx(
                      () => Container(
                        width: 80,
                        padding: const EdgeInsets.only(left: 8, right: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              profileController.selectedDialCode.value,
                            ), // or selectedCountry
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Address", style: TextStyle(fontSize: 16)),
                ),
                SizedBox(height: 5),
                AppTextField(hintText: "Enter your Address"),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Fleet", style: TextStyle(fontSize: 16)),
                ),
                SizedBox(height: 5),
                AppTextField(hintText: "No of Fleet Size"),
                const SizedBox(height: 16),
                AppTextField(hintText: "Company GST(Optional)"),

                SizedBox(height: 25),
                _buildRegisterButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildRegisterButton() {
  return ElevatedButton(
    onPressed: () {
      Get.to(ProfessionLogin());
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.buttonBg,
      minimumSize: Size(double.infinity, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    child: Text("Get in now ", style: TextStyle(color: Colors.white)),
  );
}
