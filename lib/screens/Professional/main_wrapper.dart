import 'package:flutter/material.dart';
import 'ProfessionalHomePage/ProfessionalHomePageScreen.dart';
import 'FindJobs/FindJobsScreen.dart';
import 'FeedsProfessional/FeedsProfessionalScreen.dart';
import 'TripDashboard/TripDashboardScreen.dart';
import 'widgets/professional_bottom_nav_widget.dart';
import 'JobProgress/JobProgressScreen.dart';

/// Main Wrapper for Professional User Type
/// This wrapper contains bottom navigation and manages all Professional screens
class ProfessionalMainWrapper extends StatefulWidget {
  final int initialIndex;
  const ProfessionalMainWrapper({super.key, this.initialIndex = 0});

  @override
  State<ProfessionalMainWrapper> createState() =>
      _ProfessionalMainWrapperState();
}

class _ProfessionalMainWrapperState extends State<ProfessionalMainWrapper> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  // Professional screens with bottom navigation (5 items matching Figma)
  final List<Widget> _screens = [
    const ProfessionalHomePageScreen(),
    const FindJobsScreen(), // Find
    const TripDashboardScreen(), // Trips (placeholder - replace with actual Trips screen)
    const FeedsProfessionalScreen(), // Feeds
    const JobProgressScreen(), // Jobs
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
      bottomNavigationBar: ProfessionalBottomNavWidget(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
