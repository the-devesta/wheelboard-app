import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'add_vehicle.dart';
import 'add_new_driver.dart';
import 'package:get/get.dart';

class FleetVehiclesScreen extends StatefulWidget {
  @override
  State<FleetVehiclesScreen> createState() => _FleetVehiclesScreenState();
}

class _FleetVehiclesScreenState extends State<FleetVehiclesScreen> {
  bool isVehicleSelected = true; // Track tab selection

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Stack(
      children: [
        // Background image behind everything
        Positioned.fill(
          child: SvgPicture.asset(
            'assets/bgDesign.svg',
            fit: BoxFit.cover, // ensure it fills the whole screen
          ),
        ),
        // Foreground UI inside Scaffold
        Positioned(
          top: screenHeight * 0.08,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 60,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Centered label
                  const Center(
                    child: Text(
                      "Fleet",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // Left icon
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 53,
                      height: 53,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      padding: EdgeInsets.all(6),
                      child: Image.asset(
                        'assets/logobg.png', // Replace with your asset
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // Right icon
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () {
                        // Handle search press
                      },
                      icon: const Icon(Icons.search, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            padding: EdgeInsets.only(top: 10),
            margin: EdgeInsets.only(
              top: screenHeight * 0.18,
            ), // push below header if needed
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                _tabBar(),
                const SizedBox(height: 12),
                _filterButton(),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(12),
                    children: isVehicleSelected
                        ? _vehicleCards()
                        : _driverCards(),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: isVehicleSelected
              ? FloatingActionButton.extended(
                  backgroundColor: Colors.redAccent,
                  onPressed: () => Get.to(AddVehicleScreen()),
                  label: const Text(
                    '+ Add Vehicle',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : FloatingActionButton.extended(
                  backgroundColor: Colors.redAccent,
                  onPressed: () => Get.to(AddNewDriverScreen()),
                  label: const Text(
                    '+ Add Driver',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _tabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            _segmentedTabItem("Drivers", !isVehicleSelected, () {
              setState(() => isVehicleSelected = false);
            }),
            _segmentedTabItem("Vehicles", isVehicleSelected, () {
              setState(() => isVehicleSelected = true);
            }),
          ],
        ),
      ),
    );
  }

  Widget _segmentedTabItem(String title, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: selected ? Colors.redAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(40),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: selected ? Colors.white : Colors.redAccent,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _filterButton() {
    return Row(
      children: [
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.tune, color: Colors.teal),
          label: const Text("Filter", style: TextStyle(color: Colors.teal)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            elevation: 0,
            side: const BorderSide(color: Colors.teal),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _vehicleCards() {
    return [
      _vehicleCard(
        status: "In-Transit",
        statusColor: Colors.green,
        image: 'assets/truckImg.png',
        title: "Tata-2518",
        type: "Owned",
        driver: "Deepak Kumar",
        plate: "TX-23-HJ9342",
        rating: 4.2,
        borderColor: Colors.green,
      ),
      _vehicleCard(
        status: "Assigned",
        statusColor: Colors.blue,
        image: 'assets/truckImg.png',
        title: "Tata-2007",
        type: "Owned",
        driver: "Deepak Kumar",
        plate: "MH-12-AB-1234",
        rating: 4.7,
        borderColor: Colors.blue,
      ),
      _vehicleCard(
        status: "Available",
        statusColor: Colors.orange,
        image: 'assets/truckImg.png',
        title: "Omni van-1999",
        type: "Attached",
        driver: "",
        plate: "CA-55-XY9782",
        rating: 4.7,
        borderColor: Colors.orange,
      ),
      const SizedBox(height: 80),
    ];
  }

  List<Widget> _driverCards() {
    return [
      _vehicleCard(
        status: "On Duty",
        statusColor: Colors.green,
        image: 'assets/google.png',
        title: "Deepak Kumar",
        type: "Driver",
        driver: "Assigned: Tata-2518",
        plate: "TX-23-HJ9342",
        rating: 4.8,
        borderColor: Colors.green,
      ),
      _vehicleCard(
        status: "Available",
        statusColor: Colors.orange,
        image: 'assets/google.png',
        title: "Amit Sharma",
        type: "Driver",
        driver: "Assigned: None",
        plate: "N/A",
        rating: 4.5,
        borderColor: Colors.orange,
      ),
    ];
  }

  Widget _vehicleCard({
    required String status,
    required Color statusColor,
    required String image,
    required String title,
    required String type,
    required String driver,
    required String plate,
    required double rating,
    required Color borderColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              const SizedBox(height: 8),
              Image.asset(image, height: 50, width: 60, fit: BoxFit.cover),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$title  $type",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (driver.isNotEmpty)
                  Text(driver, style: const TextStyle(fontSize: 13)),
                Text("Plate: $plate", style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.red, size: 16),
                    Text(
                      rating.toString(),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: const [
              Icon(Icons.favorite_border, color: Colors.red),
              SizedBox(height: 8),
              Icon(Icons.edit, size: 18),
            ],
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, size: 14),
        ],
      ),
    );
  }
}
