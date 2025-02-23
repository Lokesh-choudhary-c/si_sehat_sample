// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:appointment_mgmt_app/consts/colors.dart';
import 'package:appointment_mgmt_app/screens/account_screen/account_screen.dart';
import 'package:appointment_mgmt_app/screens/calender_screen/calender_screen.dart';
import 'package:appointment_mgmt_app/screens/chat_screen/chat_screen.dart';
import 'package:appointment_mgmt_app/screens/history_screen/history_screen.dart';
import 'package:appointment_mgmt_app/screens/homepage/homepage.dart';
import 'package:appointment_mgmt_app/res/services/db_service/rt.dart';
import 'package:flutter/material.dart';

class BottomNavScreen extends StatefulWidget {
  final String name;

  const BottomNavScreen({super.key, required this.name});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _currentIndex = 0;
  String? doctorId; 
  final RealtimeDatabaseService _databaseService = RealtimeDatabaseService();

  @override
  void initState() {
    super.initState();
    _fetchLatestDoctorId();
  }

  Future<void> _fetchLatestDoctorId() async {

    final bookingsData = await _databaseService.readData("bookings");

    if (bookingsData != null) {
      Map<String, dynamic> bookingsMap = Map<String, dynamic>.from(bookingsData);
      for (var entry in bookingsMap.entries) {
        Map<String, dynamic> booking = Map<String, dynamic>.from(entry.value);
        if (booking["patientName"] == widget.name) {
          setState(() {
            doctorId = booking["doctorId"]; 
          });
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _screens = [
      HomepageScreen(name: widget.name),
      const CalenderScreen(),
      HistoryScreen(),
      ChatScreen(doctorId: doctorId ?? '', patientId: widget.name),
      AccountScreen(),
    ];

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Calendar"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
        ],
      ),
    );
  }
}
