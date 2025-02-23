import 'dart:async';
import 'package:appointment_mgmt_app/consts/colors.dart';
import 'package:appointment_mgmt_app/consts/images.dart';
import 'package:appointment_mgmt_app/consts/strings.dart';
import 'package:appointment_mgmt_app/screens/bottom_navigation/bottom_bar.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeBackState();
}

class _WelcomeBackState extends State<WelcomeScreen> {
  String? _name;
  Timer? _timer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final name = ModalRoute.of(context)?.settings.arguments as String?;
    setState(() {
      _name = name;
    });
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BottomNavScreen(name: _name ?? ''),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
               height: 100,
               width: 100,
               decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(25), 
               ),
               child: ClipRRect(
                 borderRadius: BorderRadius.circular(25), 
                   child: Image.asset(
                     AppAssets.icIcon,
                     fit: BoxFit.cover, 
                   ),
                 ),
               ),

            const SizedBox(height: 20),
            Text(
              "Hello ${_name ?? 'User'} 👋",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              AppString.welcomeToSiSehatMobileApps,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
