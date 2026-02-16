import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import '../../controllers/Transport/dashboard_controller.dart';
import '../../models/dashboard_model.dart';
import '../../widgets/custom_loader.dart';
import 'job_screen.dart';
import 'job_form_screen.dart';
import 'job_application_screen.dart';
import 'trips_screen.dart';
import 'fleet_screen.dart';
import '../Professional/TransactionSummary/TransactionSummaryScreen.dart';
import '../../utils/app_logger.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());

    return Scaffold(
      backgroundColor: const Color(
        0xFFF5F7FA,
      ), // Light grey background for better contrast
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const BackButton(color: Colors.black87),
        title: Text(
          "Dashboard",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const CustomLoader(message: "Loading dashboard...");
        }

        if (controller.errorMessage.value.isNotEmpty &&
            controller.dashboardData.value == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.fetchDashboardData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final data = controller.dashboardData.value;
        if (data == null) {
          return const Center(child: Text('No data available'));
        }

        return RefreshIndicator(
          onRefresh: controller.fetchDashboardData,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------------- Metrics Section ----------------
                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
                    // Provide more height for cards to prevent overflow
                    final double itemHeight = 130;
                    final double itemWidth =
                        (constraints.maxWidth - (crossAxisCount - 1) * 12) /
                        crossAxisCount;
                    final double childAspectRatio = itemWidth / itemHeight;

                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: childAspectRatio,
                      children: [
                        _statCard(
                          Icons.directions_car,
                          "Active Trips",
                          "${data.tripSummary.totalTrips} Trips",
                          "${data.tripSummary.scheduledToday} Scheduled Today",
                          Colors.green,
                        ),
                        GestureDetector(
                          onTap: () =>
                              Get.to(() => const FleetVehiclesScreen()),
                          child: _statCard(
                            Icons.local_shipping,
                            "Active Vehicles",
                            "${data.activeVehicles.activeVehicles} Active",
                            "${data.activeVehicles.inMaintenance} in Maintenance",
                            Colors.blue,
                          ),
                        ),
                        _statCard(
                          Icons.wallet,
                          "Monthly Expenses",
                          "₹${_formatCurrency(data.monthlyExpenses.totalExpenses)}",
                          data.monthlyExpenses.highestFuelAmount > 0
                              ? "Highest Fuel: ₹${_formatCurrency(data.monthlyExpenses.highestFuelAmount)}"
                              : "No expenses",
                          Colors.red,
                        ),
                        _statCard(
                          Icons.work,
                          "Jobs Posted",
                          "${data.jobsSummary.activeJobs} Active",
                          "${data.jobsSummary.unfilledJobs} Unfilled",
                          Colors.purple,
                        ),
                        _statCard(
                          Icons.route,
                          "Trip Efficiency",
                          data.tripEfficiency?.avgCostPerKm != null
                              ? "₹${data.tripEfficiency!.avgCostPerKm!.toStringAsFixed(1)}/km"
                              : "N/A",
                          data.tripEfficiency?.totalKmPerMonth != null
                              ? "${_formatNumber(data.tripEfficiency!.totalKmPerMonth!)} km/mo"
                              : "No data",
                          Colors.teal,
                        ),
                        _statCard(
                          Icons.car_rental,
                          "Vehicles on Lease",
                          data.vehiclesOnLease != null
                              ? "${data.vehiclesOnLease!.total}"
                              : "0",
                          data.vehiclesOnLease != null &&
                                  data.vehiclesOnLease!.leasedThisWeek > 0
                              ? "+${data.vehiclesOnLease!.leasedThisWeek} this week"
                              : "No new leases",
                          Colors.orange,
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 24),

                // ---------------- Trip Completion Trend ----------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _sectionTitle("Trip Completion Trend"),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "Last 7 Days",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  height: 280,
                  padding: const EdgeInsets.fromLTRB(12, 24, 24, 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _buildTripCompletionChart(data.tripCompletionTrend),
                ),

                const SizedBox(height: 24),

                // ---------------- Vehicle Availability ----------------
                Card(
                  color: Colors.white,
                  elevation: 2,
                  shadowColor: Colors.black.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              "Vehicle Availability",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _availabilityItem(
                              "${data.vehicleAvailability.available}",
                              "Available",
                              Colors.green,
                              Icons.check_circle_outline,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.grey[200],
                            ),
                            _availabilityItem(
                              "${data.vehicleAvailability.onTrip}",
                              "On Trip",
                              Colors.blue,
                              Icons.directions_car,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.grey[200],
                            ),
                            _availabilityItem(
                              "${data.vehicleAvailability.onRent}",
                              "On Rent",
                              Colors.orange,
                              Icons.key,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ---------------- Top Rated Professionals ----------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _sectionTitle("Top Rated Professionals"),
                    if (data.topProfessionals.length > 3)
                      Obx(
                        () => TextButton(
                          onPressed: () =>
                              controller.showAllProfessionals.toggle(),
                          child: Text(
                            controller.showAllProfessionals.value
                                ? "Show Less"
                                : "View All",
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Obx(() {
                  // Get unique professional types from data
                  final Set<String> professionalTypes = {'All'};
                  for (var professional in data.topProfessionals) {
                    if (professional.professionalType.isNotEmpty) {
                      professionalTypes.add(professional.professionalType);
                    } else {
                      professionalTypes.add('Other');
                    }
                  }

                  final List<String> filterOptions = professionalTypes.toList()
                    ..sort();

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: filterOptions.map((filter) {
                        final isSelected =
                            controller.selectedProfessionalFilter.value ==
                            filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () =>
                                controller.setProfessionalFilter(filter),
                            child: _chip(filter, isSelected),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                Obx(() {
                  // Filter professionals based on selected filter
                  List<TopProfessional> filteredProfessionals =
                      data.topProfessionals;

                  if (controller.selectedProfessionalFilter.value != 'All') {
                    filteredProfessionals = data.topProfessionals.where((
                      professional,
                    ) {
                      if (controller.selectedProfessionalFilter.value ==
                          'Other') {
                        return professional.professionalType.isEmpty;
                      }
                      return professional.professionalType ==
                          controller.selectedProfessionalFilter.value;
                    }).toList();
                  }

                  final displayedList = controller.showAllProfessionals.value
                      ? filteredProfessionals
                      : filteredProfessionals.take(3).toList();

                  return filteredProfessionals.isNotEmpty
                      ? Column(
                          children: displayedList.map((professional) {
                            final role =
                                professional.professionalType.isNotEmpty
                                ? "${professional.professionalType} • ${professional.city}"
                                : professional.city;
                            // Fix image URL - replace backslashes with forward slashes
                            String imageUrl = professional.driverImagePath
                                .replaceAll('\\', '/');
                            return _professionalTile(
                              professional.fullName,
                              role,
                              imageUrl: imageUrl,
                            );
                          }).toList(),
                        )
                      : _emptyState(
                          "No professionals available for this filter",
                        );
                }),

                const SizedBox(height: 24),

                // ---------------- Jobs You Posted ----------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _sectionTitle("Jobs You Posted"),
                    TextButton(
                      onPressed: () => Get.to(() => const JobsScreen()),
                      child: const Text("View All"),
                    ),
                  ],
                ),
                ...(data.jobList.isNotEmpty
                    ? data.jobList.take(3).map((job) {
                        final jobTitle =
                            job.role ?? job.jobType ?? "Untitled Job";
                        return _jobCard(
                          jobTitle,
                          "${job.applicants ?? 0} Applicants",
                          "${job.likeCount ?? 0} Likes",
                          job.city ?? "",
                          job.salary ?? 0,
                          onView: () => Get.to(
                            () => JobApplicationsScreen(jobId: job.jobId),
                          ),
                          onEdit: () => Get.to(() => const JobsScreen()),
                        );
                      }).toList()
                    : [_emptyState("No jobs posted")]),
                const SizedBox(height: 12),
                _addButtonWithAction(
                  "+ Post New Job",
                  const Color(0xFFF44336),
                  () => Get.to(() => const PostJobScreen()),
                ),

                const SizedBox(height: 24),

                // ---------------- Expense Overview ----------------
                _sectionTitle("Expense Overview"),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _buildExpenseOverviewChart(data.recentTransactions),
                ),

                const SizedBox(height: 24),

                // ---------------- Recent Transactions ----------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _sectionTitle("Recent Transactions"),
                    TextButton(
                      onPressed: () => Get.to(() => TransactionSummaryScreen()),
                      child: const Text("View All"),
                    ),
                  ],
                ),
                ...(data.recentTransactions.isNotEmpty
                    ? data.recentTransactions.take(5).map((transaction) {
                        IconData icon;
                        Color iconColor;
                        final expenseType =
                            transaction.expenseType?.toLowerCase() ?? '';
                        switch (expenseType) {
                          case 'fuel':
                            icon = Icons.local_gas_station;
                            iconColor = Colors.blue;
                            break;
                          case 'maintenance':
                            icon = Icons.build;
                            iconColor = Colors.orange;
                            break;
                          case 'challan':
                            icon = Icons.receipt;
                            iconColor = Colors.orangeAccent;
                            break;
                          case 'advance':
                            icon = Icons.account_balance_wallet;
                            iconColor = Colors.purple;
                            break;
                          case 'salary':
                            icon = Icons.payments;
                            iconColor = Colors.green;
                            break;
                          case 'food':
                            icon = Icons.restaurant;
                            iconColor = Colors.redAccent;
                            break;
                          default:
                            icon = Icons.receipt_long;
                            iconColor = Colors.grey;
                        }

                        // Format date
                        String formattedDate = "Unknown date";
                        if (transaction.dateEntered != null) {
                          try {
                            final date = DateTime.parse(
                              transaction.dateEntered!,
                            );
                            formattedDate =
                                "${date.day} ${_getMonthName(date.month)} • ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
                          } catch (e) {
                            formattedDate = transaction.dateEntered!;
                          }
                        }

                        return _transactionTile(
                          icon: icon,
                          iconColor: iconColor,
                          title: transaction.expenseType ?? "Transaction",
                          subtitle: formattedDate,
                          amount: transaction.amount != null
                              ? "₹${_formatCurrency(transaction.amount!)}"
                              : "₹0",
                        );
                      }).toList()
                    : [_emptyState("No recent transactions")]),
                const SizedBox(height: 12),
                _addButtonWithAction(
                  "+ Add Expense",
                  const Color(0xFF1A73E8),
                  () => Get.to(() => TransactionSummaryScreen()),
                ),

                const SizedBox(height: 24),

                // ---------------- Assigned Services ----------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _sectionTitle("Assigned Services"),
                    if (data.assignedServices.length > 3)
                      Obx(
                        () => TextButton(
                          onPressed: () =>
                              controller.showAllAssignedServices.toggle(),
                          child: Text(
                            controller.showAllAssignedServices.value
                                ? "Show Less"
                                : "View All",
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Obx(() {
                  final displayedServices =
                      controller.showAllAssignedServices.value
                      ? data.assignedServices
                      : data.assignedServices.take(3).toList();

                  return data.assignedServices.isNotEmpty
                      ? Column(
                          children: displayedServices.map((service) {
                            // Format date
                            String formattedDate = "Unknown";
                            if (service.dateModified != null) {
                              try {
                                final date = DateTime.parse(
                                  service.dateModified!,
                                );
                                final now = DateTime.now();
                                final difference = now.difference(date);

                                if (difference.inDays == 0) {
                                  formattedDate = "Today";
                                } else if (difference.inDays == 1) {
                                  formattedDate = "Yesterday";
                                } else if (difference.inDays < 7) {
                                  formattedDate =
                                      "${difference.inDays} days ago";
                                } else if (difference.inDays < 30) {
                                  formattedDate =
                                      "${(difference.inDays / 7).floor()} weeks ago";
                                } else {
                                  formattedDate =
                                      "${(difference.inDays / 30).floor()} months ago";
                                }
                              } catch (e) {
                                formattedDate = service.dateModified!;
                              }
                            }

                            return _serviceTile(
                              title: service.serviceTitle ?? "Service",
                              desc: service.category?.isNotEmpty == true
                                  ? service.category!
                                  : "No category",
                              tag: service.category?.isNotEmpty == true
                                  ? service.category!
                                  : "General",
                              updatedAt: formattedDate,
                              onDelete: () {
                                AppLogger.d("Delete tapped");
                              },
                            );
                          }).toList(),
                        )
                      : _emptyState("No assigned services");
                }),

                const SizedBox(height: 24),

                // ---------------- Upcoming Trips ----------------
                _sectionTitle("Upcoming Trips"),
                const SizedBox(height: 12),
                ...(data.upcomingTrips.isNotEmpty
                    ? data.upcomingTrips.take(3).map((trip) {
                        return _tripTile(
                          id: trip.tripCode ?? "N/A",
                          route:
                              "${trip.pickupLocation ?? 'N/A'} to ${trip.deliveryLocation ?? 'N/A'}",
                          time:
                              "${trip.pickupDate?.split('T')[0] ?? ''} ${trip.pickupTime ?? ''}",
                          driver: trip.driverName ?? "Driver not assigned",
                          onManage: () {
                            Get.to(() => const TripPage());
                          },
                        );
                      }).toList()
                    : [_emptyState("No upcoming trips")]),

                const SizedBox(height: 40),
                Center(
                  child: Column(
                    children: [
                      Text(
                        "App v1.3.2",
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Terms & Conditions  •  Privacy Policy",
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ---------------- Helper Methods ----------------
  static String _formatCurrency(double amount) {
    if (amount >= 10000000) {
      return "${(amount / 10000000).toStringAsFixed(2)}Cr";
    } else if (amount >= 100000) {
      return "${(amount / 100000).toStringAsFixed(1)}L";
    } else if (amount >= 1000) {
      return "${(amount / 1000).toStringAsFixed(1)}k";
    }
    return amount.toStringAsFixed(0);
  }

  static String _formatNumber(double number) {
    if (number >= 1000) {
      return "${(number / 1000).toStringAsFixed(1)}k";
    }
    return number.toStringAsFixed(0);
  }

  static String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  static Widget _emptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(color: Colors.grey[500], fontSize: 14),
        ),
      ),
    );
  }

  // ---------------- Reusable Widgets ----------------
  static Widget _statCard(
    IconData icon,
    String title,
    String value,
    String subtitle,
    Color accentColor, {
    Color backgroundColor = Colors.white,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: accentColor, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: accentColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _availabilityItem(
    String value,
    String label,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: color.withOpacity(0.8), size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  static Widget _chip(String text, bool selected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? Colors.blue : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? Colors.blue : Colors.grey.shade300,
          width: selected ? 2 : 1,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: selected ? Colors.white : Colors.grey[700],
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          fontSize: 13,
        ),
      ),
    );
  }

  static Widget _professionalTile(
    String name,
    String role, {
    String imageUrl = "https://via.placeholder.com/150",
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200, width: 2),
              ),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey[100],
                backgroundImage: NetworkImage(imageUrl),
                onBackgroundImageError: (_, __) {},
                child: imageUrl.isEmpty
                    ? const Icon(Icons.person, color: Colors.grey)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _jobCard(
    String title,
    String applicants,
    String likes,
    String city,
    double salary, {
    VoidCallback? onView,
    VoidCallback? onEdit,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (city.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              city,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (salary > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          "₹${_formatCurrency(salary)}",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _pill(applicants, Colors.blue.shade50, Colors.blue),
                    const SizedBox(height: 6),
                    _pill(likes, Colors.red.shade50, Colors.red),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _outlinedButtonWithAction("View", Colors.blue, onView),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _outlinedButtonWithAction("Edit", Colors.grey, onEdit),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _pill(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  static Widget _outlinedButtonWithAction(
    String text,
    Color color,
    VoidCallback? onPressed,
  ) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withOpacity(0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
        visualDensity: VisualDensity.compact,
      ),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }

  static Widget _transactionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String amount,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        ),
        trailing: Text(
          amount,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: amount.startsWith('-') ? Colors.red : Colors.green,
          ),
        ),
      ),
    );
  }

  static Widget _addButtonWithAction(
    String text,
    Color color,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  static Widget _serviceTile({
    required String title,
    required String desc,
    required String tag,
    required String updatedAt,
    required VoidCallback onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              desc,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(
                      updatedAt,
                      style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                    ),
                  ],
                ),
                InkWell(
                  onTap: onDelete,
                  borderRadius: BorderRadius.circular(20),
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _tripTile({
    required String id,
    required String route,
    required String time,
    required String driver,
    required VoidCallback onManage,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_shipping,
                    color: Colors.teal,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Trip #$id",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        route,
                        style: const TextStyle(
                          color: Colors.teal,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Departure",
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Driver",
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        driver,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: OutlinedButton(
                onPressed: onManage,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.blue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Manage Trip",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  // Trip Completion Trend Chart
  static Widget _buildTripCompletionChart(List<TripCompletionTrend> trendData) {
    if (trendData.isEmpty) {
      return Center(
        child: Text(
          "No trend data available",
          style: TextStyle(color: Colors.grey[500]),
        ),
      );
    }

    // Initialize with 0s for Mon-Sun
    final List<double> tripData = List.filled(7, 0.0);

    final dayMap = {
      'Monday': 0,
      'Tuesday': 1,
      'Wednesday': 2,
      'Thursday': 3,
      'Friday': 4,
      'Saturday': 5,
      'Sunday': 6,
    };

    for (var item in trendData) {
      if (item.dayName != null) {
        // Handle case variations if necessary, though API typically returns Title Case
        final day = item.dayName!;
        // Simple flexible matching (e.g. "Wed" or "Wednesday")
        int? index;
        dayMap.forEach((key, val) {
          if (day.toLowerCase().startsWith(key.toLowerCase().substring(0, 3))) {
            index = val;
          }
        });

        if (index != null) {
          tripData[index!] = item.completedTrips?.toDouble() ?? 0.0;
        }
      }
    }

    final chartData = tripData.take(7).toList();
    final maxY = chartData.isEmpty
        ? 30.0
        : (chartData.reduce((a, b) => a > b ? a : b) * 1.2).clamp(
            10.0,
            double.infinity,
          );

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY > 0 ? maxY / 5 : 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey.shade100, strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                if (value.toInt() >= 0 && value.toInt() < days.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      days[value.toInt()],
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: maxY > 0 ? maxY / 5 : 5,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value == meta.min || value == meta.max) {
                  return const Text('');
                }
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(chartData.length, (index) {
              return FlSpot(index.toDouble(), chartData[index]);
            }),
            isCurved: true,
            color: Colors.blueAccent,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: Colors.blueAccent,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Colors.blueAccent.withOpacity(0.3),
                  Colors.blueAccent.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Expense Overview Chart (Donut Chart)
  static Widget _buildExpenseOverviewChart(
    List<RecentTransaction> transactions,
  ) {
    if (transactions.isEmpty) {
      return Center(
        child: Text(
          "No expense data available",
          style: TextStyle(color: Colors.grey[500]),
        ),
      );
    }

    // Group transactions
    final Map<String, double> categoryTotals = {};
    final Map<String, Color> categoryColors = {
      'Advance': Colors.purpleAccent,
      'Fuel': Colors.redAccent,
      'Challan': Colors.orangeAccent,
      'Food': Colors.amber,
      'Salary': Colors.green,
      'Enroute': Colors.lightBlue,
      'Maintenance': Colors.blueGrey,
    };

    for (var transaction in transactions) {
      final category = transaction.expenseType ?? 'Other';
      final amount = transaction.amount ?? 0.0;
      categoryTotals[category] = (categoryTotals[category] ?? 0.0) + amount;
    }

    if (categoryTotals.isEmpty) {
      return Center(
        child: Text(
          "No expense data available",
          style: TextStyle(color: Colors.grey[500]),
        ),
      );
    }

    final expenses = categoryTotals.entries.map((entry) {
      return {
        'category': entry.key,
        'amount': entry.value,
        'color': categoryColors[entry.key] ?? Colors.grey,
      };
    }).toList();

    // Sort by amount descending
    expenses.sort(
      (a, b) => (b['amount'] as double).compareTo(a['amount'] as double),
    );

    final totalAmount = expenses.fold<double>(
      0,
      (sum, item) => sum + (item['amount'] as double),
    );

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: Stack(
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 60,
                  sections: expenses.map((expense) {
                    final amount = expense['amount'] as double;
                    final isLarge = amount / totalAmount > 0.15;
                    return PieChartSectionData(
                      value: amount,
                      title: isLarge
                          ? "${(amount / totalAmount * 100).toStringAsFixed(0)}%"
                          : "",
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      color: expense['color'] as Color,
                      radius: isLarge ? 50 : 40,
                    );
                  }).toList(),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Total",
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                    Text(
                      _formatCurrency(totalAmount),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Legend
        Wrap(
          spacing: 16,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: expenses.map((expense) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: expense['color'] as Color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  expense['category'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
