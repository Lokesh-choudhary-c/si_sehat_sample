import 'package:appointment_mgmt_app/consts/colors.dart';
import 'package:appointment_mgmt_app/screens/bottom_navigation/bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:appointment_mgmt_app/consts/images.dart';

class ConfirmationScreen extends StatelessWidget {
  final String doctorName;
  final String specialty;
  final String appointmentDate;
  final String doctorImage;
  final String patientName; 

  const ConfirmationScreen({
    super.key,
    required this.doctorName,
    required this.specialty,
    required this.appointmentDate,
    required this.doctorImage,
    required this.patientName, 
  });

  @override
  Widget build(BuildContext context) {
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
                  const SizedBox(height: 50), 
                  const Text(
                    "You have successfully made \nan appointment",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "The appointment confirmation has been sent to your email.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),

                  CircleAvatar(radius: 35, backgroundImage: AssetImage(doctorImage)),
                  const SizedBox(height: 10),
                  Text(doctorName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 10),
                  Text(specialty, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Image.asset(AppAssets.icBookAppointment, width: 50, height: 50),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Appointment", style: TextStyle(fontSize: 14, color: Colors.grey)),
                          const SizedBox(height: 5),
                          Text(
                            appointmentDate,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 100),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                           context,
                           MaterialPageRoute(
                           builder: (context) => BottomNavScreen(name: patientName),
                           ),
                          );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Back to home", style: TextStyle(fontSize: 16, color: Colors.white)),
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
                    image: DecorationImage(image: AssetImage(AppAssets.icIcon)),
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
