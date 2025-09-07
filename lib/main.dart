// import 'package:flutter/material.dart';
// import 'screens/PreLogin/onboarding_screen.dart';
// import 'package:get/get.dart';
// import 'dart:io';
// import './theme/apptheme.dart';

// class MyHttpOverrides extends HttpOverrides {
//   @override
//   HttpClient createHttpClient(SecurityContext? context) {
//     return super.createHttpClient(context)
//       ..badCertificateCallback =
//           (X509Certificate cert, String host, int port) => true;
//   }
// }

// void main() {
//   HttpOverrides.global = MyHttpOverrides();
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'WheelBoard',
//       themeMode: ThemeMode.system,
//       home: RegisterScreen(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';

import './theme/apptheme.dart';
import './screens/login.dart';
import './screens/company_signup.dart';
import './screens/complete_company_profile.dart';
import './screens/bottom_navigation.dart';
import './utils/session_manager.dart'; // <-- create this file
import './screens/PreLogin/onboarding_screen.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
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
    final loggedIn = await SessionManager.isLoggedIn();
    final profileCompleted = await SessionManager.isProfileCompleted();

    await Future.delayed(const Duration(seconds: 2)); // just for splash effect

    if (!loggedIn) {
      Get.offAll(() => RegisterScreen()); // not logged in → Login
    } else if (!profileCompleted) {
      Get.offAll(
        () => ProfessionLogin(),
      ); // logged in but incomplete → Complete Register
    } else {
      Get.offAll(() => const BottomNavScreen()); // logged in & complete → Home
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
