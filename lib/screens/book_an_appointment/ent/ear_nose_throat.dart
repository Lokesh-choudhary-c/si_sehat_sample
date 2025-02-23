// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'package:appointment_mgmt_app/consts/images.dart';
import 'package:appointment_mgmt_app/res/models/doctors.dart';
import 'package:appointment_mgmt_app/screens/book_an_appointment/ent/doctors_appointment.dart';
import 'package:flutter/material.dart';
import 'package:appointment_mgmt_app/consts/colors.dart';
import 'package:appointment_mgmt_app/consts/strings.dart';
import 'package:firebase_database/firebase_database.dart';

class EarNoseThroat extends StatefulWidget {
  final String name;

  const EarNoseThroat({super.key, required this.name});

  @override
  _EarNoseThroatState createState() => _EarNoseThroatState();
}

class _EarNoseThroatState extends State<EarNoseThroat> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref("doctors");
  List<Doctor> _doctors = [];
  bool _isLoading = true;
  StreamSubscription<DatabaseEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  void _fetchDoctors() {
    _subscription = _database.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null && data is Map<dynamic, dynamic>) {
        List<Doctor> tempDoctors = [];
        data.forEach((key, value) {
          tempDoctors.add(Doctor.fromRTDB(Map<String, dynamic>.from(value)));
        });

        setState(() {
          _doctors = tempDoctors;
          _isLoading = false;
        });
      } else {
        setState(() {
          _doctors = [];
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          AppString.earNoseAndThroat,
          style: TextStyle(color: AppColors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_doctors.isEmpty)
              const Center(
                child: Text(
                  "No doctors available",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              )
            else
              Expanded( 
                child: ListView.builder(
                  itemCount: _doctors.length,
                  itemBuilder: (context, index) {
                    final doctor = _doctors[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DoctorsAppointment(
                              doctor: doctor, 
                              patientName: widget.name, 
                            ),
                          ),
                        );
                      },
                      child: _buildDoctorCard(doctor),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
  Widget _buildDoctorCard(Doctor doctor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: doctor.image == AppAssets.imgDoctorImg
                ? Image.asset(
                    doctor.image, 
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  )
                : Image.network(
                    doctor.image, 
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.person, size: 48, color: Colors.black),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  doctor.specialty,
                  style: const TextStyle(fontSize: 14, color: AppColors.black),
                ),
                const SizedBox(height: 4),
                Text(
                  doctor.price,
                  style: const TextStyle(fontSize: 16, color: AppColors.black,fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Column(
            children: [
              const Icon(Icons.star, size: 20, color: Colors.orange),
              Text(
                doctor.rating.toStringAsFixed(1), 
                style: const TextStyle(fontSize: 14, color: AppColors.black),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
