import 'package:flutter/material.dart';
import 'package:wheelboard/constants/apps_colors.dart';
import 'feed_screen.dart';
import 'home_screen.dart';
import 'job_screen.dart';
import 'fleet_screen.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  _BottomNavScreenState createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    FleetVehiclesScreen(),
    Center(child: Text("Trips")),
    FeedScreen(),
    JobsScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // More than 3 items
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: AppColors.buttonBg,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: "Fleet",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.alt_route), label: "Trips"),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: "Feeds"),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: "Jobs"),
        ],
      ),
    );
  }
}
