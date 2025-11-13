import 'package:flutter/material.dart';
import 'package:wheelboard/constants/apps_colors.dart';
import 'package:wheelboard/screens/CompanyTransport/service_dashboard.dart';
import 'home_screen.dart';
import '../CompanyTransport/services_screen.dart';
import '../CompanyTransport/feed_screen.dart';
import '../CompanyTransport/job_screen.dart';

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

  final List<Widget> _screens = [
    const ServiceProviderHomeScreen(), // Home
    const ServiceDashboardScreen(), // Listings
    const FeedScreen(), // Feeds
    const JobsScreen(), // Jobs
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Colors.grey.withOpacity(0.2),
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          selectedItemColor: AppColors.buttonBg,
          unselectedItemColor: const Color(0xFF535353),
          backgroundColor: Colors.white,
          elevation: 0,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: "Listings",
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
      ),
    );
  }
}


