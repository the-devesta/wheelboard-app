import 'package:flutter/material.dart';
import 'package:wheelboard/constants/apps_colors.dart';
import '../CompanyTransport/service_dashboard.dart';
import '../CompanyTransport/services_screen.dart';

/// Main Wrapper for Company Service Provider User Type
/// This wrapper contains bottom navigation and manages all Service Provider screens
class CompanyServiceProviderMainWrapper extends StatefulWidget {
  final int initialIndex;
  const CompanyServiceProviderMainWrapper({super.key, this.initialIndex = 0});

  @override
  State<CompanyServiceProviderMainWrapper> createState() => _CompanyServiceProviderMainWrapperState();
}

class _CompanyServiceProviderMainWrapperState extends State<CompanyServiceProviderMainWrapper> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  // TODO: Import and add your Service Provider screens here
  final List<Widget> _screens = [
    ServiceDashboardScreen(), // Home/Dashboard for Service Provider
    ServicesScreen(), // Services screen
    const _PlaceholderScreen(title: "Service Provider Feed"), // Feed
    const _PlaceholderScreen(title: "Service Provider Profile"), // Profile
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
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.room_service),
            label: "Services",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: "Feed",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

// Placeholder widget - replace with actual screens
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

