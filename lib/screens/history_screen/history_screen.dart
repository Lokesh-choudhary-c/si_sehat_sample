// ignore_for_file: depend_on_referenced_packages, use_key_in_widget_constructors, library_private_types_in_public_api, empty_catches

import 'package:appointment_mgmt_app/consts/colors.dart';
import 'package:appointment_mgmt_app/screens/chat_screen/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final DatabaseReference _appointmentsRef =
      FirebaseDatabase.instance.ref('appointments');
  final String _currentUserId = FirebaseAuth.instance.currentUser!.uid;
  List<Map<String, dynamic>> _appointments = [];

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    try {
      DatabaseEvent event = await _appointmentsRef
          .orderByChild('patientId')
          .equalTo(_currentUserId)
          .once();


      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;

        setState(() {
          _appointments = data.entries.map((entry) {
            var value = entry.value as Map<dynamic, dynamic>? ?? {};

            return {
              'id': entry.key,
              'doctorName': value['doctorName'] ?? 'Queue Appointment',
              'doctorSpecialty': value['doctorSpecialty'] ?? 'Unknown Specialty',
              'doctorImage': value['doctorImage'] ?? 'assets/default_doctor.png',
              'appointmentDate': value['appointmentDate'] ?? '',
              'appointmentTime': value['appointmentTime'] ?? '',
            };
          }).toList();
        });

      } else {
      }
    } catch (e) {
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Appointment History",
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.blue,
      ),
      body: _appointments.isEmpty
          ? const Center(child: Text("No appointment history available"))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _appointments.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _showAppointmentDialog(_appointments[index]),
                  child: _buildAppointmentCard(_appointments[index]),
                );
              },
            ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    DateTime appointmentDate;
    DateTime time;
    
    try {
      appointmentDate = DateFormat('yyyy-MM-dd').parse(appointment['appointmentDate']);
    } catch (e) {
      appointmentDate = DateTime.now();
    }

    try {
      time = _parseTime(appointment['appointmentTime']);
    } catch (e) {
      time = DateTime.now();
    }

    String shortDay = DateFormat('E').format(appointmentDate);
    String formattedDate = DateFormat('MMM dd, yyyy').format(appointmentDate);
    String formattedTime = DateFormat('hh:mm a').format(time);
    String period = time.hour < 12 ? 'Morning set' : 'Afternoon set';

    return Container(
      width: 350,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.blue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage(appointment['doctorImage']),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment['doctorName'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      appointment['doctorSpecialty'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(doctorId: '', patientId: ''),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.message, color: AppColors.black),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 25, 42, 96),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_month, color: Colors.white, size: 20),
                    const SizedBox(width: 5),
                    Text(
                      "$shortDay, $formattedDate",
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.white, size: 20),
                    const SizedBox(width: 5),
                    Text(
                      "$period, $formattedTime",
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAppointmentDialog(Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Appointment Details"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Doctor: ${appointment['doctorName']}"),
              Text("Specialty: ${appointment['doctorSpecialty']}"),
              Text("Date: ${appointment['appointmentDate']}"),
              Text("Time: ${appointment['appointmentTime']}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  DateTime _parseTime(String timeStr) {
    try {
      return DateFormat('HH:mm').parse(timeStr);
    } catch (e) {
      return DateTime.now();
    }
  }
}
