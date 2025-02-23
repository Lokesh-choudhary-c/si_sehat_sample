// ignore_for_file: use_build_context_synchronously

import 'package:appointment_mgmt_app/consts/colors.dart';
import 'package:appointment_mgmt_app/consts/images.dart';
import 'package:appointment_mgmt_app/consts/strings.dart';
import 'package:appointment_mgmt_app/screens/bottom_navigation/bottom_bar.dart';
import 'package:appointment_mgmt_app/screens/onboarding_screen/onboarding_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });
    Future.delayed( Duration(milliseconds: 1), () {
      Navigator.pushReplacement(
        context,
      MaterialPageRoute(builder: (context) => FirebaseAuth.instance.currentUser != null ? BottomNavScreen(name: FirebaseAuth.instance.currentUser?.displayName ?? '') : const OnboardingScreen())
      );
    });
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: AppColors.white,
    body: Stack(
      children: [
        Center(
          child: Image.asset(AppAssets.icLogo, scale: 0.9),
        ),
        const Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.all(18.0),
            child: Text(
              AppString.sisehatmobileapp,
              style: TextStyle(
                color: AppColors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
}






