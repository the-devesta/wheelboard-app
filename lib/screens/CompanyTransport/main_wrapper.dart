import 'package:flutter/material.dart';
import 'package:wheelboard/constants/apps_colors.dart';
import 'home_screen.dart';
import 'fleet_screen.dart';
import 'trips_screen.dart';
import 'feed_screen.dart';
import 'job_screen.dart';

/// Main Wrapper for Company Transport User Type
/// This wrapper contains bottom navigation and manages all Company Transport screens
class CompanyTransportMainWrapper extends StatefulWidget {
  final int initialIndex;
  const CompanyTransportMainWrapper({super.key, this.initialIndex = 0});

  @override
  State<CompanyTransportMainWrapper> createState() => _CompanyTransportMainWrapperState();
}

class _CompanyTransportMainWrapperState extends State<CompanyTransportMainWrapper> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _screens = [
    HomeScreen(),
    FleetVehiclesScreen(),
    TripPage(),
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
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: AppColors.buttonBg,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: "Fleet",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.alt_route),
            label: "Trips",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: "Feeds",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: "Jobs",
          ),
        ],
      ),
    );
  }
}

