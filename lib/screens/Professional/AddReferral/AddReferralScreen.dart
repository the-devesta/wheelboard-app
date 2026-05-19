import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wheelboard/controllers/Professional/add_referral_controller.dart';
import 'package:wheelboard/utils/constants.dart';
import '../NewReferral/newreferralscreen.dart';

class AddReferralScreen extends StatelessWidget {
  AddReferralScreen({super.key});
  final AddReferralController controller = Get.put(AddReferralController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => NewReferralScreen()),
        backgroundColor: const Color(0xFFFF5E5E),
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text(
          "NEW REFERRAL",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFFF5E5E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Your Referrals",
          style: TextStyle(
            color: Color(0xFFFF5E5E),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => controller.getReferrals(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Recent Referrals Header
                Text(
                  "Recent Referrals",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),

                /// Referral List
                if (controller.referrals.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 50,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "No referrals found",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.referrals.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final r = controller.referrals[index];
                      final status = r.referralStatus.toLowerCase();

                      Color statusColor;
                      IconData statusIcon;

                      if (status == "accepted") {
                        statusColor = Colors.green;
                        statusIcon = Icons.check_circle;
                      } else if (status == "rejected") {
                        statusColor = Colors.red;
                        statusIcon = Icons.cancel;
                      } else {
                        statusColor = Colors.orange;
                        statusIcon = Icons.pending;
                      }

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    r.fullName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    r.role,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    formatDateShort(r.createdDate),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    statusIcon,
                                    size: 14,
                                    color: statusColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    status.capitalizeFirst!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: statusColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      }),
    );
  }
}
