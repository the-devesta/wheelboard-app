import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wheelboard/commonwidget/app_textfield.dart';
import 'package:wheelboard/constants/apps_colors.dart';

/// ----------------------------
/// Google Places Suggestion Model
/// ----------------------------
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

/// ----------------------------
/// New Trip Screen
/// ----------------------------
class Newtripscreen extends StatefulWidget {
  const Newtripscreen({super.key});

  @override
  State<Newtripscreen> createState() => _ScheduleTripScreenState();
}

class _ScheduleTripScreenState extends State<Newtripscreen> {
  String? selectedVehicle;
  String? selectedDriver;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  final TextEditingController pickupController = TextEditingController();
  final TextEditingController deliveryController = TextEditingController();

  final Color fieldBorderColor = const Color.fromARGB(255, 199, 198, 198);

  final PlacesService placesService = PlacesService(
    apiKey: "AIzaSyDD1jdzyCZ_QhA4QpsL9qFRg38phVn8mPI",
  ); // <-- put your key here

  List<Suggestion> pickupSuggestions = [];
  List<Suggestion> deliverySuggestions = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9DCDC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'New Post Trip',
          style: TextStyle(color: Colors.black),
        ),
        leading: const BackButton(color: Colors.black),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.close, color: Colors.black),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "Trip Details",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _buildDropdown(
                label: "Select Vehicle",
                value: selectedVehicle,
                hint: "Select Vehicle",
                items: ["Truck A", "Van B", "Bike C"],
                onChanged: (val) => setState(() => selectedVehicle = val),
              ),
              const SizedBox(height: 16),

              _buildDropdown(
                label: "Select Driver",
                value: selectedDriver,
                hint: "Select Driver",
                items: ["John", "Rahul", "Ankit"],
                onChanged: (val) => setState(() => selectedDriver = val),
              ),
              const SizedBox(height: 16),

              _buildPickupField(),
              const SizedBox(height: 16),

              _buildDeliveryField(),
              const SizedBox(height: 16),

              _buildDatePicker(context),
              const SizedBox(height: 16),

              _buildTimePicker(context),
              const SizedBox(height: 16),

              AppTextField(hintText: 'Special Instructions'),
              const SizedBox(height: 16),
              AppTextField(hintText: 'Enter Pay range (Rs 200 - Rs900)'),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Submit action
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonBg,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0xFF2B5DF2)),
                    ),
                  ),
                  child: const Text(
                    "Schedule Now",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPickupField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Pickup Location"),
        const SizedBox(height: 6),
        TextFormField(
          controller: pickupController,
          decoration: _inputDecoration(
            hint: "Enter pickup location",
            borderColor: fieldBorderColor,
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
              border: Border.all(color: fieldBorderColor),
              borderRadius: BorderRadius.circular(12),
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

                    // Optional: fetch lat/lng
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

  Widget _buildDeliveryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Delivery Location"),
        const SizedBox(height: 6),
        TextFormField(
          controller: deliveryController,
          decoration: _inputDecoration(
            hint: "Enter delivery location",
            borderColor: fieldBorderColor,
          ),
          onChanged: (value) async {
            if (value.isNotEmpty) {
              final results = await placesService.fetchSuggestions(value);
              setState(() => deliverySuggestions = results); // ✅ fixed
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
              border: Border.all(color: fieldBorderColor),
              borderRadius: BorderRadius.circular(12),
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

  Widget _buildDropdown({
    required String label,
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          hint: Text(hint),
          isExpanded: true,
          decoration: _inputDecoration(borderColor: fieldBorderColor),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          decoration: _inputDecoration(
            hint: hint,
            borderColor: fieldBorderColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Pick up a Date"),
        const SizedBox(height: 6),
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
              color: Colors.blue,
            ),
            borderColor: fieldBorderColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Pick Time"),
        const SizedBox(height: 6),
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
            suffixIcon: const Icon(Icons.access_time, color: Colors.blue),
            borderColor: fieldBorderColor,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    String? hint,
    Widget? suffixIcon,
    Color? borderColor,
  }) {
    final color = borderColor ?? Theme.of(context).primaryColor;

    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: 2.0),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color),
      ),
    );
  }
}
