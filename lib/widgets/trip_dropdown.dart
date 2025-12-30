import 'package:flutter/material.dart';

class TripDropdown extends StatelessWidget {
  final String? selectedValue;
  final Function(String?) onChanged;
  final List<TripItem> items;

  const TripDropdown({
    super.key,
    required this.selectedValue,
    required this.onChanged,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (context) {
        return [
          PopupMenuItem<String>(
            enabled: false,
            child: Container(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Color(0xFFF36969),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Select Trip",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFF36969),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ...items.map((item) {
            return PopupMenuItem<String>(
              value: item.tripId,
              child: Container(
                margin: const EdgeInsets.only(bottom: 3),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Origin
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 12,
                                color: Color(0xFF2196F3),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  item.origin,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFFF36969),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Arrow
                        const Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: Color(0xFFADAEBC),
                        ),
                        const SizedBox(width: 8),
                        // Destination
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 12,
                                color: Color(0xFFFF5E5E),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  item.destination,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFFF36969),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Trip ID
                        Flexible(
                          child: Text(
                            "Trip ID: ${item.tripId}",
                            style: TextStyle(
                              fontSize: 10,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF27AE60),
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Vehicle Type
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Vehicle Type: ",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF27AE60),
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  item.vehicleType,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFFFF5E5E),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // Date
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Date: ",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF27AE60),
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  item.date,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFFFF5E5E),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ];
      },
      onSelected: onChanged,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 13),
        child: Row(
          children: [
            Expanded(
              child: Builder(
                builder: (context) {
                  if (selectedValue != null && items.isNotEmpty) {
                    try {
                      final trip = items.firstWhere(
                        (t) => t.tripId == selectedValue,
                      );
                      return Text(
                        "${trip.origin} → ${trip.destination}",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF424242),
                        ),
                      );
                    } catch (e) {
                      return Text(
                        "Select trip",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFADAEBC),
                        ),
                      );
                    }
                  }
                  return Text(
                    "Select trip",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFADAEBC),
                    ),
                  );
                },
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: Color(0xFF424242),
            ),
          ],
        ),
      ),
    );
  }
}

class TripItem {
  final String tripId;
  final String origin;
  final String destination;
  final String vehicleType;
  final String date;

  TripItem({
    required this.tripId,
    required this.origin,
    required this.destination,
    required this.vehicleType,
    required this.date,
  });
}
