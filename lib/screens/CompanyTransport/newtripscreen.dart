import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../../controllers/add_trip_controller.dart';
import '../../utils/session_manager.dart';
import '../../models/add_new_trip_model.dart';
import 'dart:math';

class Newtripscreen extends StatefulWidget {
  const Newtripscreen({super.key});

  @override
  State<Newtripscreen> createState() => _ScheduleTripScreenState();
}

class _ScheduleTripScreenState extends State<Newtripscreen> {
  final TripController tripController = Get.put(TripController());

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  final TextEditingController pickupController = TextEditingController();
  final TextEditingController deliveryController = TextEditingController();
  final TextEditingController specialInstructionsController =
      TextEditingController();
  final TextEditingController minPayRangeController = TextEditingController();
  final TextEditingController maxPayRangeController = TextEditingController();
  final PlacesService placesService = PlacesService(
    apiKey: "AIzaSyDD1jdzyCZ_QhA4QpsL9qFRg38phVn8mPI",
  ); // <-- put your key here

  List<Suggestion> pickupSuggestions = [];
  List<Suggestion> deliverySuggestions = [];

  @override
  void initState() {
    super.initState();

    _FetchDrivers();
    _FetchVehicles();
  }

  Future<void> _FetchDrivers() async {
    final sessionManager = SessionManager();
    final token = await sessionManager.getString("authToken");
    final userId = await sessionManager.getString("userId");

    // print(userId);
    // print(token);

    if (token != null && userId != null) {
      tripController.fetchDrivers(userId, token);
    } else {
      debugPrint("Token or UserId is null");
    }
  }

  Future<void> _FetchVehicles() async {
    final sessionManager = SessionManager();
    final token = await sessionManager.getString("authToken");
    final userId = await sessionManager.getString("userId");

    // print(userId);
    // print(token);

    if (token != null && userId != null) {
      tripController.fetchVehicles(userId, token);
    } else {
      debugPrint("Token or UserId is null");
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
          'New Post Trip',
          style: TextStyle(
            color: Color(0xFF1E1E1E),
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            letterSpacing: -0.14,
          ),
        ),
        leading: const BackButton(color: Colors.black),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.close, color: Colors.black, size: 20),
          ),
        ],
        shape: const Border(
          bottom: BorderSide(
            color: Color(0xFFFCD2D2),
            width: 1,
          ),
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

                _buildPickupField(),
                const SizedBox(height: 17),

                _buildDeliveryField(),
                const SizedBox(height: 17),

                _buildDatePicker(context),
                const SizedBox(height: 17),

                _buildTimePicker(context),
                const SizedBox(height: 17),

                _buildSpecialInstructionsField(),
                const SizedBox(height: 17),

                _buildPayRangeFields(),
                const SizedBox(height: 24),

                Center(
                  child: SizedBox(
                    width: 295,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        final token = await SessionManager().getString("authToken");
                        final userId = await SessionManager().getString("userId");

                        if (token == null || userId == null) {
                          Get.snackbar("Error", "User not logged in");
                          return;
                        }

                        // Combine min and max pay range for backend (temporary - backend will change later)
                        final payRange = minPayRangeController.text.isNotEmpty && maxPayRangeController.text.isNotEmpty
                            ? "Rs ${minPayRangeController.text} - Rs ${maxPayRangeController.text}"
                            : "";

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
                          specialInstructions: specialInstructionsController.text,
                          payRange: payRange,
                          tripCode: "TRIP-${DateTime.now().millisecondsSinceEpoch}",
                          tripStatus: "Pending",
                        );

                        // ✅ Send API call
                        await tripController.addTrip(trip, token);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF25C5C),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
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
            value: tripController.selectedVehicle.value,
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

  // Widget _buildDriverDropdown() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Text("Select Driver"),
  //       const SizedBox(height: 6),
  //       Obx(() {
  //         if (tripController.isLoading.value) {
  //           return const CircularProgressIndicator(); // Show loading indicator
  //         }
  //         if (tripController.drivers.isEmpty) {
  //           return const Text("No drivers available");
  //         }
  //         return DropdownButtonFormField<String>(
  //           value: tripController.selectedDriver.value,
  //           hint: const Text("Select Driver"),
  //           isExpanded: true,
  //           decoration: _inputDecoration(borderColor: fieldBorderColor),
  //           items: tripController.drivers
  //               .map(
  //                 (driver) => DropdownMenuItem(
  //                   value: driver.driverId, // Use driver ID as the value
  //                   child: Text(driver.fullName), // Display driver name
  //                 ),
  //               )
  //               .toList(),
  //           onChanged: (val) => tripController.selectedDriver.value = val,
  //         );
  //       }),
  //     ],
  //   );
  // }

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return "${dt.hour.toString().padLeft(2, '0')}:"
        "${dt.minute.toString().padLeft(2, '0')}:00";
  }

  // Widget _buildPickupField() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Text("Pickup Location"),
  //       const SizedBox(height: 6),
  //       TextFormField(
  //         controller: pickupController,
  //         decoration: _inputDecoration(
  //           hint: "Enter pickup location",
  //           borderColor: fieldBorderColor,
  //         ),
  //       ),
  //     ],
  //   );
  // }
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

                    final loc = await placesService.fetchPlaceLocation(
                      s.placeId,
                    );
                    debugPrint("Pickup LatLng: $loc");
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  // Widget _buildDeliveryField() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Text("Delivery Location"),
  //       const SizedBox(height: 6),
  //       TextFormField(
  //         controller: deliveryController,
  //         decoration: _inputDecoration(
  //           hint: "Enter delivery location",
  //           borderColor: fieldBorderColor,
  //         ),
  //       ),
  //     ],
  //   );
  // }

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
                    debugPrint("Delivery LatLng: $loc");
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

  Widget _buildSpecialInstructionsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Special Instructions",
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
          controller: specialInstructionsController,
          maxLines: 3,
          decoration: _inputDecoration(
            hint: "Enter special instructions",
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

  Widget _buildPayRangeFields() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Min Pay Range (Rs)",
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
                controller: minPayRangeController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration(
                  hint: "200",
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
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Max Pay Range (Rs)",
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
                controller: maxPayRangeController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration(
                  hint: "900",
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
}

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

/// ----------------------------
/// Google Places Service
/// ----------------------------
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
