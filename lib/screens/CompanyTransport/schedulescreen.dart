import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/Transport/add_trip_controller.dart';
import '../../utils/session_manager.dart';
import '../../utils/distance_service.dart';
import '../../utils/location_service.dart';
import '../../models/add_new_trip_model.dart';
import 'dart:math';
import '../../utils/constants.dart';
import '../../utils/app_logger.dart';

class ScheduleTripScreen extends StatefulWidget {
  const ScheduleTripScreen({super.key});

  @override
  State<ScheduleTripScreen> createState() => _ScheduleTripScreenState();
}

class _ScheduleTripScreenState extends State<ScheduleTripScreen> {
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
  double? _pickupLat;
  double? _pickupLng;

  @override
  void initState() {
    super.initState();
    _FetchDrivers();
    _FetchVehicles();
  }

  Future<void> _FetchDrivers() async {
    final sessionManager = SessionManager();
    final userId = await sessionManager.getString("userId");

    if (userId != null && userId.isNotEmpty) {
      tripController.fetchDrivers(userId);
    } else {
      AppLogger.d("UserId is null or empty");
    }
  }

  Future<void> _FetchVehicles() async {
    final sessionManager = SessionManager();
    final userId = await sessionManager.getString("userId");

    if (userId != null && userId.isNotEmpty) {
      tripController.fetchVehicles(userId);
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
        title: Text(
          'Schedule Your Trip',
          style: GoogleFonts.poppins(
            color: const Color(0xFF2D3436),
            fontSize: 18,
            fontWeight: FontWeight.w600,
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
                      "Trip Details",
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
                const SizedBox(height: 24),

                Center(
                  child: SizedBox(
                    width: 295,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        final userId = await SessionManager().getString(
                          "userId",
                        );
                        // Validation: Check if vehicle is selected
                        if (tripController.selectedVehicle.value == null ||
                            tripController.selectedVehicle.value!.isEmpty) {
                          Get.snackbar(
                            "Required",
                            "Please select a vehicle",
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        // Validation: Check if driver is selected
                        if (tripController.selectedDriver.value == null ||
                            tripController.selectedDriver.value!.isEmpty) {
                          Get.snackbar(
                            "Required",
                            "Please select a driver",
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        if (userId == null || userId.isEmpty) {
                          Get.snackbar("Error", "User not logged in");
                          return;
                        }

                        // 🔍 DEBUG: Log selected values before creating trip
                        AppLogger.d("=================================");
                        AppLogger.d("🚚 SCHEDULE TRIP - DEBUG INFO");
                        AppLogger.d("=================================");
                        AppLogger.d("👤 User ID: $userId");
                        AppLogger.d(
                          "🚗 Selected Vehicle ID: ${tripController.selectedVehicle.value ?? 'NOT SELECTED'}",
                        );
                        AppLogger.d(
                          "👨‍✈️ Selected Driver ID: ${tripController.selectedDriver.value ?? 'NOT SELECTED'}",
                        );
                        AppLogger.d(
                          "📍 Pickup Location: ${pickupController.text}",
                        );
                        AppLogger.d(
                          "📍 Delivery Location: ${deliveryController.text}",
                        );
                        AppLogger.d("📅 Pickup Date: $selectedDate");
                        AppLogger.d(
                          "⏰ Pickup Time: ${selectedTime != null ? _formatTimeOfDay(selectedTime!) : '00:00:00'}",
                        );
                        AppLogger.d(
                          "📝 Special Instructions: ${specialInstructionsController.text.trim()}",
                        );
                        AppLogger.d(
                          "💰 Pay Range: ${payRangeController.text.trim()}",
                        );
                        AppLogger.d("=================================");

                        // ✅ Build Trip object (TripId not needed - backend will generate)
                        final trip = Trip(
                          tripId: "", // Empty - backend will generate TripId
                          userId: userId,
                          vehicleId: tripController.selectedVehicle.value ?? "",
                          driverId: tripController.selectedDriver.value ?? "",
                          pickupLocation: pickupController.text,
                          deliveryLocation: deliveryController.text,
                          pickupDate: selectedDate,
                          pickupTime: selectedTime != null
                              ? _formatTimeOfDay(selectedTime!)
                              : "00:00:00",
                          specialInstructions: specialInstructionsController
                              .text
                              .trim(),
                          payRange: payRangeController.text.trim(),
                          tripCode:
                              "TRIP-${DateTime.now().millisecondsSinceEpoch}",
                          tripStatus: "Pending",
                          isScheduledTrip:
                              true, // ✅ This is a scheduled trip with driver selection
                          latitude: _pickupLat,
                          longitude: _pickupLng,
                          distance: _distanceResult != null
                              ? "${_distanceResult!.distanceKm.toStringAsFixed(2)} km"
                              : "",
                        );

                        // 🔍 DEBUG: Log Trip object after creation
                        AppLogger.d("=================================");
                        AppLogger.d("📦 TRIP OBJECT CREATED");
                        AppLogger.d("=================================");
                        AppLogger.d("Trip ID: ${trip.tripId}");
                        AppLogger.d("User ID: ${trip.userId}");
                        AppLogger.d("Vehicle ID: ${trip.vehicleId}");
                        AppLogger.d(
                          "👨‍✈️ Driver ID: ${trip.driverId} ${trip.driverId.isEmpty ? '❌ EMPTY!' : '✅ HAS VALUE'}",
                        );
                        AppLogger.d("Pickup Location: ${trip.pickupLocation}");
                        AppLogger.d(
                          "Delivery Location: ${trip.deliveryLocation}",
                        );
                        AppLogger.d("Pickup Date: ${trip.pickupDate}");
                        AppLogger.d("Pickup Time: ${trip.pickupTime}");
                        AppLogger.d(
                          "Special Instructions: ${trip.specialInstructions}",
                        );
                        AppLogger.d("Pay Range: ${trip.payRange}");
                        AppLogger.d("Trip Code: ${trip.tripCode}");
                        AppLogger.d("Trip Status: ${trip.tripStatus}");
                        AppLogger.d("=================================");

                        // ✅ Send API call (userId-based auth, no token needed)
                        await tripController.addTrip(trip);
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
                      child: const Text(
                        "Schedule Now",
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
          return DropdownButtonFormField<String>(
            initialValue: tripController.selectedVehicle.value,
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
            onChanged: (val) => tripController.selectedVehicle.value = val,
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
          return DropdownButtonFormField<String>(
            initialValue: tripController.selectedDriver.value,
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
            onChanged: (val) => tripController.selectedDriver.value = val,
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

  /// Get current location and fill in the controller
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
          if (controller == pickupController) {
            _pickupLat = position?.latitude;
            _pickupLng = position?.longitude;
          }
        });

        // Auto-calculate distance if both locations are set
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
          'Could not get current location. Please check permissions.',
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
              try {
                final results = await placesService.fetchSuggestions(value);
                setState(() => pickupSuggestions = results);
              } catch (e) {
                AppLogger.e('Error fetching pickup suggestions: $e');
              }
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

                    try {
                      final loc = await placesService.fetchPlaceLocation(
                        s.placeId,
                      );
                      AppLogger.d("Pickup LatLng: $loc");

                      setState(() {
                        _pickupLat = loc['lat'];
                        _pickupLng = loc['lng'];
                      });
                    } catch (e) {
                      AppLogger.e("Error fetching place location: $e");
                    }

                    // Auto-calculate distance if both locations are set
                    _autoCalculateDistance();
                  },
                );
              },
            ),
          ),
        // Current Location Button for Pickup
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

                    final loc = await placesService.fetchPlaceLocation(
                      s.placeId,
                    );
                    AppLogger.d("Delivery LatLng: $loc");

                    // Auto-calculate distance if both locations are set
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
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
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
              initialTime: TimeOfDay.now(),
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

  // Estimated Distance Widget
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
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Text(
              _isCalculatingDistance
                  ? "Calculating..."
                  : _distanceResult != null && _distanceResult!.distanceKm > 0
                  ? "${_distanceResult!.distanceKm.toStringAsFixed(2)} km"
                  : hasLocations
                  ? "Tap to calculate distance"
                  : "Enter both locations to calculate",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color:
                    _distanceResult != null && _distanceResult!.distanceKm > 0
                    ? const Color(0xFFF57C00)
                    : Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.local_shipping,
                color: Color(0xFF0288D1),
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _distanceResult != null &&
                          _distanceResult!.durationMinutes > 0
                      ? "Estimated truck travel time: ${_distanceResult!.truckDurationText}"
                      : "Estimated travel time will appear here",
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        _distanceResult != null &&
                            _distanceResult!.durationMinutes > 0
                        ? const Color(0xFF0288D1)
                        : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          if (hasLocations &&
              (_distanceResult == null || _distanceResult!.distanceKm == 0))
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: GestureDetector(
                onTap: _calculateDistance,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF57C00),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    "Calculate Distance",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _calculateDistance() async {
    if (pickupController.text.isEmpty || deliveryController.text.isEmpty) {
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
        'Error',
        'Failed to calculate distance',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Auto-calculate distance when both locations are selected
  void _autoCalculateDistance() {
    // Add small delay to ensure state is updated
    Future.delayed(const Duration(milliseconds: 300), () {
      if (pickupController.text.isNotEmpty &&
          deliveryController.text.isNotEmpty) {
        _calculateDistance();
      }
    });
  }
}

// Suggestion class for Google Places
class Suggestion {
  final String placeId;
  final String description;
  final String sector;
  final String city;
  final String state;
  final String country;
  final String subTitle;

  Suggestion({
    required this.placeId,
    required this.description,
    required this.sector,
    required this.city,
    required this.state,
    required this.country,
    required this.subTitle,
  });

  factory Suggestion.fromPrediction(Map<String, dynamic> p) {
    final terms = (p['terms'] as List<dynamic>?) ?? [];
    final sector = _getTerm(terms, 4);
    final city = _getTerm(terms, 3);
    final state = _getTerm(terms, 2);
    final country = _getTerm(terms, 1);

    final parts = [
      if (sector.isNotEmpty) sector,
      if (city.isNotEmpty) city,
      if (state.isNotEmpty) state,
    ];
    final subTitle =
        (parts.join(', ') + (country.isNotEmpty ? ', $country' : '')).trim();

    return Suggestion(
      placeId: p['place_id'] as String? ?? '',
      description: (p['description'] as String? ?? '').trim(),
      sector: sector,
      city: city,
      state: state,
      country: country,
      subTitle: subTitle,
    );
  }

  static String _getTerm(List<dynamic> terms, int indexFromEnd) {
    final index = terms.length - indexFromEnd;
    if (index >= 0 && index < terms.length) {
      final val = terms[index];
      if (val is Map && val['value'] != null) return val['value'] as String;
    }
    return '';
  }
}

// Google Places Service
class PlacesService {
  final String apiKey;
  final http.Client client;

  PlacesService({required this.apiKey, http.Client? client})
    : client = client ?? http.Client();

  Future<List<Suggestion>> fetchSuggestions(String input) async {
    final encoded = Uri.encodeQueryComponent(input);
    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json'
        '?input=$encoded'
        '&types=establishment|geocode'
        '&language=en'
        '&components=country:in'
        '&key=$apiKey';

    final resp = await client.get(Uri.parse(url));
    if (resp.statusCode != 200) {
      throw Exception('Failed: ${resp.statusCode}');
    }

    final result = json.decode(resp.body) as Map<String, dynamic>;
    final status = result['status'] as String? ?? 'UNKNOWN';

    if (status == 'OK') {
      final preds = result['predictions'] as List<dynamic>;
      return preds
          .map((p) => Suggestion.fromPrediction(p as Map<String, dynamic>))
          .toList();
    } else if (status == 'ZERO_RESULTS') {
      return [];
    } else {
      throw Exception(result['error_message'] ?? 'Places API error: $status');
    }
  }

  Future<Map<String, double>> fetchPlaceLocation(String placeId) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json'
        '?place_id=${Uri.encodeQueryComponent(placeId)}'
        '&fields=geometry'
        '&key=$apiKey';

    final resp = await client.get(Uri.parse(url));
    if (resp.statusCode != 200) throw Exception('HTTP ${resp.statusCode}');
    final body = json.decode(resp.body) as Map<String, dynamic>;
    final status = body['status'] as String?;
    if (status == 'OK') {
      final loc =
          body['result']['geometry']['location'] as Map<String, dynamic>;
      return {
        'lat': (loc['lat'] as num).toDouble(),
        'lng': (loc['lng'] as num).toDouble(),
      };
    } else {
      throw Exception(body['error_message'] ?? 'Details error: $status');
    }
  }
}

/// Generate proper UUID v4 format (GUID) for TripId
/// Format: xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx
String generateTripId() {
  final random = Random();
  final timestamp = DateTime.now().microsecondsSinceEpoch;

  // Generate UUID v4 format: 8-4-4-4-12 (hexadecimal)
  String generateHexSegment(int length, Random rng, int seed) {
    final hex = '0123456789abcdef';
    final buffer = StringBuffer();
    for (int i = 0; i < length; i++) {
      buffer.write(hex[rng.nextInt(16)]);
    }
    return buffer.toString();
  }

  // Part 1: 8 hex digits
  final part1 = generateHexSegment(8, random, timestamp);

  // Part 2: 4 hex digits
  final part2 = generateHexSegment(4, random, timestamp);

  // Part 3: 4 hex digits starting with '4' (version 4)
  final part3 = '4${generateHexSegment(3, random, timestamp)}';

  // Part 4: 4 hex digits with variant bits (8, 9, a, or b)
  final variant = ['8', '9', 'a', 'b'][random.nextInt(4)];
  final part4 = '$variant${generateHexSegment(3, random, timestamp)}';

  // Part 5: 12 hex digits
  final part5 = generateHexSegment(12, random, timestamp);

  return '$part1-$part2-$part3-$part4-$part5';
}
