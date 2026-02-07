import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../../controllers/Transport/add_trip_controller.dart';
import '../../utils/session_manager.dart';
import '../../utils/distance_service.dart';
import '../../utils/location_service.dart';
import '../../models/add_new_trip_model.dart';
import '../../utils/constants.dart';
import '../../utils/app_logger.dart';

class EditTripScreen extends StatefulWidget {
  final Trip trip;

  const EditTripScreen({super.key, required this.trip});

  @override
  State<EditTripScreen> createState() => _EditTripScreenState();
}

class _EditTripScreenState extends State<EditTripScreen> {
  final TripController tripController = Get.put(TripController());

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  final TextEditingController pickupController = TextEditingController();
  final TextEditingController deliveryController = TextEditingController();
  final TextEditingController specialInstructionsController =
      TextEditingController();
  final TextEditingController payRangeController = TextEditingController();

  final PlacesService placesService = PlacesService(
    apiKey: MapsConstants.googleMapsApiKey,
  );

  List<Suggestion> pickupSuggestions = [];
  List<Suggestion> deliverySuggestions = [];

  // Distance calculation state
  DistanceResult? _distanceResult;
  bool _isCalculatingDistance = false;
  bool _isLoadingLocation = false;

  double? _deliveryLat;
  double? _deliveryLng;

  @override
  void initState() {
    super.initState();
    _FetchDrivers();
    _FetchVehicles();
    _prefillTripData();
  }

  /// Prefill the form with existing trip data
  void _prefillTripData() {
    final trip = widget.trip;

    pickupController.text = trip.pickupLocation;
    deliveryController.text = trip.deliveryLocation;
    specialInstructionsController.text = trip.specialInstructions;
    payRangeController.text = trip.payRange;

    // Set the date
    if (trip.pickupDate != null) {
      selectedDate = trip.pickupDate;
    }

    // Parse and set the time
    if (trip.pickupTime.isNotEmpty) {
      final timeParts = trip.pickupTime.split(':');
      if (timeParts.length >= 2) {
        final hour = int.tryParse(timeParts[0]) ?? 0;
        final minute = int.tryParse(timeParts[1]) ?? 0;
        selectedTime = TimeOfDay(hour: hour, minute: minute);
      }
    }

    // Pre-select vehicle
    if (trip.vehicleId.isNotEmpty) {
      tripController.selectedVehicle.value = trip.vehicleId;
    }

    // Pre-select driver
    if (trip.driverId.isNotEmpty) {
      tripController.selectedDriver.value = trip.driverId;
    }

    _deliveryLat = trip.latitude;
    _deliveryLng = trip.longitude;
    _distanceResult = trip.distance != null && trip.distance!.isNotEmpty
        ? DistanceResult(
            distanceKm:
                double.tryParse(trip.distance!.replaceAll(' km', '')) ?? 0,
            durationMinutes: 0,
            distanceText: trip.distance!,
            durationText: "",
            truckDurationText: "",
          )
        : null;

    setState(() {});
  }

  Future<void> _FetchDrivers() async {
    final sessionManager = SessionManager();
    final userId = await sessionManager.getString("userId");

    if (userId != null && userId.isNotEmpty) {
      await tripController.fetchDrivers(userId);
      // Set the selected driver after fetching
      if (widget.trip.driverId.isNotEmpty) {
        tripController.selectedDriver.value = widget.trip.driverId;
      }
    } else {
      AppLogger.d("UserId is null or empty");
    }
  }

  Future<void> _FetchVehicles() async {
    final sessionManager = SessionManager();
    final userId = await sessionManager.getString("userId");

    if (userId != null && userId.isNotEmpty) {
      await tripController.fetchVehicles(userId);
      // Set the selected vehicle after fetching
      if (widget.trip.vehicleId.isNotEmpty) {
        tripController.selectedVehicle.value = widget.trip.vehicleId;
      }
    } else {
      AppLogger.d("UserId is null or empty");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4E3E3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Edit Trip',
          style: TextStyle(
            color: Color(0xFF1E1E1E),
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            letterSpacing: -0.14,
          ),
        ),
        leading: const BackButton(color: Colors.black),
        shape: const Border(
          bottom: BorderSide(color: Color(0xFFFCD2D2), width: 1),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            margin: const EdgeInsets.only(top: 24),
            width: 343,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      "Edit Trip Details",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: const Color(0xFF6C7278),
                        letterSpacing: -0.32,
                      ),
                    ),
                  ),
                ),

                _buildVehicleDropdown(),
                const SizedBox(height: 17),

                _buildDriverDropdown(),
                const SizedBox(height: 17),

                _buildPickupField(),
                const SizedBox(height: 17),

                _buildDeliveryField(),
                const SizedBox(height: 17),

                // Estimated Distance Widget
                _buildEstimatedDistanceWidget(),
                const SizedBox(height: 17),

                _buildDatePicker(context),
                const SizedBox(height: 17),

                _buildTimePicker(context),
                const SizedBox(height: 17),

                // Special Instructions Field
                _buildSpecialInstructionsField(),
                const SizedBox(height: 17),

                // Pay Range Field
                _buildPayRangeField(),
                const SizedBox(height: 24),

                Center(
                  child: SizedBox(
                    width: 295,
                    height: 48,
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: tripController.isLoading.value
                            ? null
                            : () async {
                                final userId = await SessionManager().getString(
                                  "userId",
                                );

                                if (userId == null || userId.isEmpty) {
                                  Get.snackbar("Error", "User not logged in");
                                  return;
                                }

                                // ✅ Build updated Trip object
                                final updatedTrip = Trip(
                                  tripId: widget.trip.tripId,
                                  userId: userId,
                                  vehicleId:
                                      tripController.selectedVehicle.value ??
                                      widget.trip.vehicleId,
                                  driverId:
                                      tripController.selectedDriver.value ??
                                      widget.trip.driverId,
                                  pickupLocation: pickupController.text,
                                  deliveryLocation: deliveryController.text,
                                  pickupDate: selectedDate,
                                  pickupTime: selectedTime != null
                                      ? _formatTimeOfDay(selectedTime!)
                                      : widget.trip.pickupTime,
                                  specialInstructions:
                                      specialInstructionsController.text.trim(),
                                  payRange: payRangeController.text.trim(),
                                  tripCode: widget.trip.tripCode,
                                  tripStatus: widget.trip.tripStatus,
                                  isScheduledTrip: true,
                                  latitude: _deliveryLat,
                                  longitude: _deliveryLng,
                                  distance: _distanceResult != null
                                      ? "${_distanceResult!.distanceKm.toStringAsFixed(2)} km"
                                      : widget.trip.distance,
                                );

                                // ✅ Call update API
                                await tripController.updateTrip(updatedTrip);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF25C5C),
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 24,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: tripController.isLoading.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Update Trip",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                  letterSpacing: -0.14,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Vehicle",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            fontFamily: 'Poppins',
            color: const Color(0xFF535353),
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          if (tripController.isVehicleLoading.value) {
            return const CircularProgressIndicator();
          }
          if (tripController.vehicles.isEmpty) {
            return const Text("No vehicles available");
          }
          final String? currentValue =
              tripController.vehicles.any(
                (v) => v.vehicleId == tripController.selectedVehicle.value,
              )
              ? tripController.selectedVehicle.value
              : null;

          return DropdownButtonFormField<String>(
            value: currentValue,
            hint: Text(
              "Select Vehicle",
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
                color: const Color(0xFF8F9098),
              ),
            ),
            isExpanded: true,
            decoration: _inputDecoration(
              borderColor: const Color(0xFFC5C6CC),
              height: 48,
            ),
            items: tripController.vehicles
                .map(
                  (vehicle) => DropdownMenuItem(
                    value: vehicle.vehicleId,
                    child: Text(vehicle.vehicleModel),
                  ),
                )
                .toList(),
            onChanged: (val) {
              if (val != null) {
                tripController.selectedVehicle.value = val;
              }
            },
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF006FFD),
              size: 12,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDriverDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Driver",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            fontFamily: 'Poppins',
            color: const Color(0xFF535353),
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          if (tripController.isLoading.value) {
            return const CircularProgressIndicator();
          }
          if (tripController.drivers.isEmpty) {
            return const Text("No drivers available");
          }
          final String? currentValue =
              tripController.drivers.any(
                (d) => d.driverId == tripController.selectedDriver.value,
              )
              ? tripController.selectedDriver.value
              : null;

          return DropdownButtonFormField<String>(
            value: currentValue,
            hint: Text(
              "Select Driver",
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Inter',
                color: const Color(0xFF1F2024),
              ),
            ),
            isExpanded: true,
            decoration: _inputDecoration(
              borderColor: const Color(0xFFC5C6CC),
              height: 48,
            ),
            items: tripController.drivers
                .map(
                  (driver) => DropdownMenuItem(
                    value: driver.driverId,
                    child: Text(
                      driver.fullName,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Inter',
                        color: const Color(0xFF1F2024),
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: (val) {
              if (val != null) {
                tripController.selectedDriver.value = val;
              }
            },
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF006FFD),
              size: 12,
            ),
          );
        }),
      ],
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return "${dt.hour.toString().padLeft(2, '0')}:"
        "${dt.minute.toString().padLeft(2, '0')}:00";
  }

  Future<void> _getCurrentLocation(TextEditingController controller) async {
    setState(() => _isLoadingLocation = true);

    try {
      final position = await LocationService.getCurrentPosition();
      final address = position != null
          ? await LocationService.getAddressFromCoordinates(
              position.latitude,
              position.longitude,
            )
          : null;

      if (address != null && address.isNotEmpty) {
        setState(() {
          controller.text = address;
        });

        _autoCalculateDistance();

        Get.snackbar(
          '✅ Success',
          'Current location filled successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          '❌ Error',
          'Could not get current location.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        '❌ Error',
        'Failed to get location: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  Widget _buildPickupField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Pickup Location",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins',
            color: const Color(0xFF6C7278),
            letterSpacing: -0.24,
          ),
        ),
        const SizedBox(height: 2),
        TextFormField(
          controller: pickupController,
          decoration: _inputDecoration(
            hint: "Enter pickup location",
            borderColor: const Color(0xFFEDF1F3),
            height: 46,
          ),
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Poppins',
            color: const Color(0xFF6C7278),
            letterSpacing: -0.14,
          ),
          onChanged: (value) async {
            if (value.isNotEmpty) {
              final results = await placesService.fetchSuggestions(value);
              setState(() => pickupSuggestions = results);
            } else {
              setState(() => pickupSuggestions = []);
            }
          },
        ),
        if (pickupSuggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFEDF1F3)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pickupSuggestions.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final s = pickupSuggestions[index];
                return ListTile(
                  title: Text(s.description),
                  subtitle: Text(s.subTitle),
                  onTap: () async {
                    setState(() {
                      pickupController.text = s.description;
                      pickupSuggestions.clear();
                    });
                    _autoCalculateDistance();
                  },
                );
              },
            ),
          ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isLoadingLocation
                ? null
                : () => _getCurrentLocation(pickupController),
            icon: _isLoadingLocation
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location, size: 18),
            label: Text(
              _isLoadingLocation
                  ? 'Getting location...'
                  : 'Use Current Location',
              style: const TextStyle(fontSize: 12),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF006FFD),
              side: const BorderSide(color: Color(0xFF006FFD)),
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Delivery Location",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            fontFamily: 'Plus Jakarta Sans',
            color: const Color(0xFF6C7278),
            letterSpacing: -0.24,
          ),
        ),
        const SizedBox(height: 2),
        TextFormField(
          controller: deliveryController,
          decoration: _inputDecoration(
            hint: "Enter delivery location",
            borderColor: const Color(0xFFEDF1F3),
            height: 46,
          ),
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Inter',
            color: const Color(0xFF6C7278),
            letterSpacing: -0.14,
          ),
          onChanged: (value) async {
            if (value.isNotEmpty) {
              final results = await placesService.fetchSuggestions(value);
              setState(() => deliverySuggestions = results);
            } else {
              setState(() => deliverySuggestions = []);
            }
          },
        ),
        if (deliverySuggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFEDF1F3)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: deliverySuggestions.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final s = deliverySuggestions[index];
                return ListTile(
                  title: Text(s.description),
                  subtitle: Text(s.subTitle),
                  onTap: () async {
                    setState(() {
                      deliveryController.text = s.description;
                      deliverySuggestions.clear();
                    });

                    try {
                      final loc = await placesService.fetchPlaceLocation(
                        s.placeId,
                      );
                      AppLogger.d("Delivery LatLng: $loc");

                      if (loc != null) {
                        setState(() {
                          _deliveryLat = loc['lat'];
                          _deliveryLng = loc['lng'];
                        });
                      }
                    } catch (e) {
                      AppLogger.e("Error fetching delivery location: $e");
                    }
                    _autoCalculateDistance();
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Pick up a Date",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            fontFamily: 'Plus Jakarta Sans',
            color: const Color(0xFF6C7278),
            letterSpacing: -0.24,
          ),
        ),
        const SizedBox(height: 2),
        TextFormField(
          readOnly: true,
          onTap: () async {
            final now = DateTime.now();
            final initialDate = selectedDate ?? now;
            final firstDate =
                selectedDate != null && selectedDate!.isBefore(now)
                ? selectedDate!
                : now;

            final date = await showDatePicker(
              context: context,
              initialDate: initialDate,
              firstDate: firstDate,
              lastDate: DateTime(2100),
            );
            if (date != null) {
              setState(() => selectedDate = date);
            }
          },
          decoration: _inputDecoration(
            hint: selectedDate == null
                ? "Choose a date"
                : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
            suffixIcon: const Icon(
              Icons.calendar_month_outlined,
              color: Color(0xFF006FFD),
              size: 21,
            ),
            borderColor: const Color(0xFFEDF1F3),
            height: 46,
          ),
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Inter',
            color: const Color(0xFF6C7278),
            letterSpacing: -0.14,
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Pick Time",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            fontFamily: 'Plus Jakarta Sans',
            color: const Color(0xFF6C7278),
            letterSpacing: -0.24,
          ),
        ),
        const SizedBox(height: 2),
        TextFormField(
          readOnly: true,
          onTap: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: selectedTime ?? TimeOfDay.now(),
            );
            if (time != null) {
              setState(() => selectedTime = time);
            }
          },
          decoration: _inputDecoration(
            hint: selectedTime == null
                ? "Pick your time."
                : selectedTime!.format(context),
            suffixIcon: const Icon(
              Icons.access_time,
              color: Color(0xFF006FFD),
              size: 21,
            ),
            borderColor: const Color(0xFFEDF1F3),
            height: 46,
          ),
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Inter',
            color: const Color(0xFF6C7278),
            letterSpacing: -0.14,
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialInstructionsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Special Instructions",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins',
            color: const Color(0xFF6C7278),
            letterSpacing: -0.24,
          ),
        ),
        const SizedBox(height: 2),
        TextFormField(
          controller: specialInstructionsController,
          maxLines: 3,
          decoration: _inputDecoration(
            hint: "Enter any special instructions...",
            borderColor: const Color(0xFFEDF1F3),
          ),
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Poppins',
            color: const Color(0xFF6C7278),
            letterSpacing: -0.14,
          ),
        ),
      ],
    );
  }

  Widget _buildPayRangeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Pay Range",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins',
            color: const Color(0xFF6C7278),
            letterSpacing: -0.24,
          ),
        ),
        const SizedBox(height: 2),
        TextFormField(
          controller: payRangeController,
          decoration: _inputDecoration(
            hint: "Enter pay range (e.g., ₹500 - ₹1000)",
            borderColor: const Color(0xFFEDF1F3),
            height: 46,
          ),
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Poppins',
            color: const Color(0xFF6C7278),
            letterSpacing: -0.14,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    String? hint,
    Widget? suffixIcon,
    Color? borderColor,
    double? height,
  }) {
    final color = borderColor ?? const Color(0xFFEDF1F3);

    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      suffixIcon: suffixIcon,
      hintStyle: TextStyle(
        fontSize: 14,
        fontFamily: 'Inter',
        color: const Color(0xFF6C7278),
        letterSpacing: -0.14,
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 14,
        vertical: height != null ? (height - 21) / 2 : 12.5,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: color, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: color, width: 1),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: color, width: 1),
      ),
      constraints: height != null ? BoxConstraints(minHeight: height) : null,
    );
  }

  Widget _buildEstimatedDistanceWidget() {
    final hasLocations =
        pickupController.text.isNotEmpty && deliveryController.text.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.route, color: Color(0xFFF57C00), size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  "Distance between Origin and Destination:",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6C7278),
                  ),
                ),
              ),
              if (_isCalculatingDistance)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (_distanceResult != null)
            Text(
              "${_distanceResult!.distanceText} (${_distanceResult!.durationText})",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFFF57C00),
              ),
            )
          else if (hasLocations && !_isCalculatingDistance)
            TextButton(
              onPressed: _calculateDistance,
              child: const Text(
                "Calculate Distance",
                style: TextStyle(color: Color(0xFF006FFD)),
              ),
            )
          else
            const Text(
              "Enter both locations to calculate distance",
              style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
            ),
        ],
      ),
    );
  }

  Future<void> _calculateDistance() async {
    if (pickupController.text.isEmpty || deliveryController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter both pickup and delivery locations",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _isCalculatingDistance = true);

    try {
      final result = await distanceService.calculateDistance(
        origin: pickupController.text,
        destination: deliveryController.text,
      );

      setState(() {
        _distanceResult = result;
        _isCalculatingDistance = false;
      });
    } catch (e) {
      setState(() => _isCalculatingDistance = false);
      Get.snackbar(
        "Error",
        "Failed to calculate distance: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _autoCalculateDistance() {
    if (pickupController.text.isNotEmpty &&
        deliveryController.text.isNotEmpty) {
      _calculateDistance();
    }
  }
}

class Suggestion {
  final String placeId;
  final String description;
  final String subTitle;

  Suggestion({
    required this.placeId,
    required this.description,
    required this.subTitle,
  });

  factory Suggestion.fromJson(Map<String, dynamic> json) {
    final terms = json['terms'] as List<dynamic>? ?? [];
    return Suggestion(
      placeId: json['place_id'] ?? '',
      description: json['description'] ?? '',
      subTitle: _getTerm(terms, 1),
    );
  }

  static String _getTerm(List<dynamic> terms, int indexFromEnd) {
    if (terms.isEmpty) return '';
    final index = terms.length - 1 - indexFromEnd;
    if (index < 0 || index >= terms.length) return '';
    return terms[index]['value'] ?? '';
  }
}

class PlacesService {
  final String apiKey;

  PlacesService({required this.apiKey});

  Future<List<Suggestion>> fetchSuggestions(String input) async {
    if (input.isEmpty) return [];

    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json'
        '?input=$input'
        '&components=country:in'
        '&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final predictions = data['predictions'] as List<dynamic>? ?? [];
        return predictions.map((p) => Suggestion.fromJson(p)).toList();
      }
    } catch (e) {
      AppLogger.d("Places API error: $e");
    }
    return [];
  }

  Future<Map<String, double>?> fetchPlaceLocation(String placeId) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json'
        '?place_id=$placeId'
        '&fields=geometry'
        '&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final location = data['result']?['geometry']?['location'];
        if (location != null) {
          return {
            'lat': location['lat']?.toDouble() ?? 0.0,
            'lng': location['lng']?.toDouble() ?? 0.0,
          };
        }
      }
    } catch (e) {
      AppLogger.d("Place Details API error: $e");
    }
    return null;
  }
}
