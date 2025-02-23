// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api, prefer_final_fields, use_build_context_synchronously

import 'package:appointment_mgmt_app/screens/qr_appointment/qrapptdetails.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class QRScannerScreen extends StatefulWidget {
  final String name;

  const QRScannerScreen({super.key, required this.name});

  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController _controller = MobileScannerController();
  bool _isLoading = false;
  bool _isTorchOn = false;
  bool _isProcessing = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
  }

Future<bool> hasActiveAppointment(String patientId) async {
  DatabaseReference ref = FirebaseDatabase.instance.ref("appointments");
  DataSnapshot snapshot = await ref.get();

  if (snapshot.exists && snapshot.value is Map) {
    Map<dynamic, dynamic> appointments = snapshot.value as Map;
    
    return appointments.values.any((appt) =>
      appt['queueSystem']?['isActive'] == true &&
      appt['patientId'] == patientId 
    );
  }
  return false;
}
void bookAppointment(String appointmentId, String patientId) async {
  if (_isProcessing) return;
  _isProcessing = true;
  _controller.stop();

  setState(() => _isLoading = true);

  bool alreadyBooked = await hasActiveAppointment(patientId);
  if (alreadyBooked) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("You already have an active appointment!")),
    );
    setState(() => _isLoading = false);
    _isProcessing = false;
    return;
  }

  DatabaseReference ref = FirebaseDatabase.instance.ref("appointments");
  DataSnapshot snapshot = await ref.get();

  DateTime currentTime = DateTime.now();
  String formattedDate = DateFormat('EEEE, dd MMM').format(currentTime);
  int queueNumber = 1;
  int queueLeft = 0;

  DateTime startTime = currentTime;

  if (snapshot.exists && snapshot.value is Map) {
    Map<dynamic, dynamic> appointments = snapshot.value as Map;

    List<Map<String, dynamic>> todaysAppointments = appointments.values
        .where((appt) => appt['date'] == formattedDate)
        .map((appt) => Map<String, dynamic>.from(appt))
        .toList();

    todaysAppointments.sort((a, b) => (a['queueSystem']['queueNumber']).compareTo(b['queueSystem']['queueNumber']));

    if (todaysAppointments.isNotEmpty) {
      String lastTimeRange = todaysAppointments.last['timeRange'];
      List<String> times = lastTimeRange.split(" - ");
      DateTime lastEndTime = DateFormat('hh:mm a').parse(times[1]);

      startTime = lastEndTime.isAfter(currentTime) ? lastEndTime : currentTime;

      queueNumber = todaysAppointments.length + 1;
      queueLeft = queueNumber - 1;
    }
  }

  DateTime estimatedEndTime = startTime.add(Duration(minutes: 15));
  String estimatedTimeRange = "${DateFormat('hh:mm a').format(startTime)} - ${DateFormat('hh:mm a').format(estimatedEndTime)}";

  String newAppointmentId = FirebaseDatabase.instance.ref("appointments").push().key!;

  await FirebaseDatabase.instance.ref("appointments/$newAppointmentId").set({
    "date": formattedDate,
    "timeRange": estimatedTimeRange,
    "patientId": patientId,
    "queueSystem": {
      "queueNumber": queueNumber,
      "queueLeft": queueLeft,
      "timeLeft": queueNumber * 15 * 60,
      "healthCenter": "XYZ Hospital",
      "isActive": true
    }
  });

  _isProcessing = false;
  _isLoading = false;

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => QrApptDetails(name: widget.name, appointmentDetails: {
        'date': formattedDate,
        'timeRange': estimatedTimeRange,
        'queueSystem': {
          'queueNumber': queueNumber,
          'queueLeft': queueLeft,
          'timeLeft': queueNumber * 15 * 60,
          'healthCenter': "XYZ Hospital",
          'isActive': true
        }
      }),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double frameSize = 250;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
  if (_isProcessing) return;

  String scannedData = capture.barcodes.first.rawValue ?? '';
  String? patientId = FirebaseAuth.instance.currentUser?.uid;

  if (scannedData == 'book_appointment' && patientId != null) {
    bookAppointment(scannedData, patientId);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: User not logged in.")),
    );
  }
},
          ),

          // Grey overlay
          Positioned.fill(
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: (screenHeight - frameSize) / 2,
                  child: Container(color: Colors.black.withOpacity(0.6)),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: (screenHeight - frameSize) / 2,
                  child: Container(color: Colors.black.withOpacity(0.6)),
                ),
                Positioned(
                  top: (screenHeight - frameSize) / 2,
                  left: 0,
                  width: (screenWidth - frameSize) / 2,
                  height: frameSize,
                  child: Container(color: Colors.black.withOpacity(0.6)),
                ),
                Positioned(
                  top: (screenHeight - frameSize) / 2,
                  right: 0,
                  width: (screenWidth - frameSize) / 2,
                  height: frameSize,
                  child: Container(color: Colors.black.withOpacity(0.6)),
                ),
              ],
            ),
          ),

          // Blue frame
          Center(
            child: Container(
              width: frameSize,
              height: frameSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue, width: 4),
              ),
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: Colors.white))
                  : null,
            ),
          ),

          // Torch and Camera Switch Icons
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.arrow_back, color: Colors.white, size: 28),
                ),
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() => _isTorchOn = !_isTorchOn);
                        _controller.toggleTorch();
                      },
                      child: Icon(
                        _isTorchOn ? Icons.flash_on : Icons.flash_off,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => _controller.switchCamera(),
                      child: Icon(Icons.cameraswitch, color: Colors.white, size: 28),
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

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }
}
