import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';

import './screens/bottom_navigation.dart';
import './screens/PreLogin/onboarding_screen.dart';
import './services/auth_service.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        // Only allow specific domains for development/testing
        // In production, this should be more restrictive
        if (host == 'wheelboardapi.addonshareware.com' || 
            host == 'localhost' || 
            host == '10.0.2.2' || 
            host == '127.0.0.1') {
          return true;
        }
        return false; // Reject certificates for other domains
      };
  }
}

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  
  // Initialize GetX services
  Get.put(AuthService());
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WheelBoard',
      themeMode: ThemeMode.system,
      home: const SplashScreen(), // 👈 start from Splash
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Wait for AuthService to initialize and check login status
    await Future.delayed(const Duration(seconds: 2)); // splash effect
    
    final authService = AuthService.to;
    
    // ✅ Wait for AuthService to finish checking login status
    await authService.refreshLoginStatus();
    
    final loggedIn = authService.isUserLoggedIn;

    print("🔐 Splash Screen Check:");
    print("🔐 Is Logged In: $loggedIn");

    if (!loggedIn) {
      print("🔐 Navigating to RegisterScreen");
      Get.offAll(() => const RegisterScreen()); // not logged in → Register/Login
    } else {
      print("🔐 Navigating to BottomNavScreen (Home) - User is logged in");
      Get.offAll(() => const BottomNavScreen()); // logged in → Home (regardless of profile completion)
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
