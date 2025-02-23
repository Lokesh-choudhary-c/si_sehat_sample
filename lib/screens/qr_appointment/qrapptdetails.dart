// ignore_for_file: use_super_parameters, library_private_types_in_public_api

import 'package:appointment_mgmt_app/consts/colors.dart';
import 'package:appointment_mgmt_app/consts/images.dart';
import 'package:appointment_mgmt_app/screens/bottom_navigation/bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class QrApptDetails extends StatefulWidget {
  final String name;
  final Map<String, dynamic>? appointmentDetails;

  const QrApptDetails({Key? key, this.appointmentDetails, required this.name}) : super(key: key);

  @override
  _QrApptDetailsState createState() => _QrApptDetailsState();
}

class _QrApptDetailsState extends State<QrApptDetails> {
  int queueLeft = 0;

  @override
  void initState() {
    super.initState();

    if (widget.appointmentDetails != null) {
      queueLeft = widget.appointmentDetails!['queueSystem']['queueLeft'] ?? 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    double progress = queueLeft > 0 ? (1 - queueLeft / 10).clamp(0.0, 1.0) : 1.0; 

    return Scaffold(
      backgroundColor: AppColors.blue,
      body: Center(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 100, left: 20, right: 20),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    "Scan Successfully",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.black),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.appointmentDetails?['queueSystem']['healthCenter'] ?? "XYZ Hospital",
                    style: const TextStyle(fontSize: 16, color: AppColors.black),
                  ),
                  const SizedBox(height: 30),
                  Image.asset(AppAssets.icBookAppointment, height: 50),
                  const SizedBox(height: 10),
                  const Text(
                    "Your Queue Number",
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.appointmentDetails?['queueSystem']['queueNumber'].toString() ?? "1",
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  CircularPercentIndicator(
                    radius: 65,
                    lineWidth: 12.0,
                    percent: progress,
                    center: Text(
                      "$queueLeft",
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    progressColor: AppColors.blue,
                    backgroundColor: Colors.grey.shade300,
                    circularStrokeCap: CircularStrokeCap.round,
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "Estimated turn time ${widget.appointmentDetails?['timeRange'] ?? '11:38 PM - 11:53 PM'}",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.appointmentDetails?['date'] ?? "Thursday, 13 Feb",
                    style: const TextStyle(fontSize: 16, color: AppColors.black, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BottomNavScreen(name: widget.name),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        "Back to home",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 20,
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: const BoxDecoration(
                  color: AppColors.blue,
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                ),
                child: Container(
                  height: 90,
                  width: 90,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                    image: DecorationImage(image: AssetImage("assets/icons/qrsuccess.png")),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
