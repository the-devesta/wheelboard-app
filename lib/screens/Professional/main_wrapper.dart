import 'package:flutter/material.dart';
import 'package:wheelboard/constants/apps_colors.dart';

/// Main Wrapper for Professional User Type
/// This wrapper contains bottom navigation and manages all Professional screens
class ProfessionalMainWrapper extends StatefulWidget {
  final int initialIndex;
  const ProfessionalMainWrapper({super.key, this.initialIndex = 0});

  @override
  State<ProfessionalMainWrapper> createState() => _ProfessionalMainWrapperState();
}

class _ProfessionalMainWrapperState extends State<ProfessionalMainWrapper> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  // TODO: Import and add your Professional screens here
  final List<Widget> _screens = [
    const _PlaceholderScreen(title: "Professional Home"),
    const _PlaceholderScreen(title: "Professional Listings"),
    const _PlaceholderScreen(title: "Professional Feeds"),
    const _PlaceholderScreen(title: "Professional Jobs"),
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

