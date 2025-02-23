// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api, empty_catches, use_build_context_synchronously

import 'package:appointment_mgmt_app/consts/colors.dart';
import 'package:appointment_mgmt_app/screens/chat_screen/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class RequestCancellation extends StatefulWidget {
  const RequestCancellation({super.key});

  @override
  _RequestCancellationState createState() => _RequestCancellationState();
}

class _RequestCancellationState extends State<RequestCancellation> {
  final DatabaseReference _appointmentsRef =
      FirebaseDatabase.instance.ref('appointments');
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";
  List<Map<String, dynamic>> _appointments = [];
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    if (_currentUserId.isNotEmpty) {
      _fetchAppointments();
      _startAutoRefresh();
    }
  }

  void _startAutoRefresh() {
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) _fetchAppointments();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _fetchAppointments() async {
    try {
      DatabaseEvent event = await _appointmentsRef
          .orderByChild('patientId')
          .equalTo(_currentUserId)
          .once();

      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> data =
            event.snapshot.value as Map<dynamic, dynamic>;

        setState(() {
          _appointments = data.entries
              .map((entry) => {
                    'id': entry.key,
                    'doctorName': entry.value['doctorName'] ?? 'Queue',
                    'doctorSpecialty': entry.value['doctorSpecialty'] ?? 'Unknown',
                    'doctorImage': entry.value['doctorImage'] ?? '',
                    'appointmentDate': entry.value['appointmentDate'] ?? '',
                    'appointmentTime': entry.value['appointmentTime'] ?? '',
                  })
              .toList();
        });
      } else {
        setState(() {
          _appointments = [];
        });
      }
    } catch (e) {
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Request Cancellation",
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
    DateTime appointmentDate = appointment['appointmentDate'].isNotEmpty
        ? DateFormat('yyyy-MM-dd').parse(appointment['appointmentDate'])
        : DateTime.now();
    DateTime time = _parseTime(appointment['appointmentTime']);

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
                backgroundImage: appointment['doctorImage'].isNotEmpty
                    ? AssetImage(appointment['doctorImage'])
                    : const AssetImage('assets/default_doctor.png'),
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
                      builder: (context) => ChatScreen(
                        doctorId: appointment['id'],
                        patientId: _currentUserId,
                      ),
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
            height: 40,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 25, 42, 96),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                const SizedBox(width: 10),
                const Icon(Icons.calendar_month, color: Colors.white, size: 20),
                const SizedBox(width: 5),
                Text("$shortDay, $formattedDate",
                    style: const TextStyle(color: Colors.white, fontSize: 14)),
                const SizedBox(width: 10),
                const Icon(Icons.access_time, color: Colors.white, size: 20),
                const SizedBox(width: 5),
                Text("$period, $formattedTime",
                    style: const TextStyle(color: AppColors.white, fontSize: 14)),
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
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showCancelConfirmation(appointment['id']);
              },
              child: const Text("Cancel Booking", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showCancelConfirmation(String appointmentId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Cancel Appointment?"),
          content: const Text("Are you sure you want to cancel this appointment?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () => _cancelAppointment(appointmentId),
              child: const Text("Yes, Cancel", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _cancelAppointment(String appointmentId) async {
    await _appointmentsRef.child(appointmentId).remove();
    _fetchAppointments();
    Navigator.pop(context);
  }

  DateTime _parseTime(String timeStr) {
    return timeStr.isNotEmpty ? DateFormat('HH:mm').parse(timeStr) : DateTime.now();
  }
}













// import 'package:appointment_mgmt_app/consts/colors.dart';
// import 'package:appointment_mgmt_app/screens/chat_screen/chat_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:intl/intl.dart';
// import 'dart:async';

// class RequestCancellation extends StatefulWidget {
//   @override
//   _HistoryScreenState createState() => _HistoryScreenState();
// }

// class _HistoryScreenState extends State<RequestCancellation> {
//   final DatabaseReference _appointmentsRef =
//       FirebaseDatabase.instance.ref('appointments');
//   final String _currentUserId = FirebaseAuth.instance.currentUser!.uid;
//   List<Map<String, dynamic>> _appointments = [];
//   late Timer _timer; // Timer to auto-refresh

//   @override
//   void initState() {
//     super.initState();
//     _fetchAppointments();
//     _startAutoRefresh();
//   }

//   // Auto-refresh the appointments list every 10 seconds
//   void _startAutoRefresh() {
//     _timer = Timer.periodic(const Duration(seconds: 10), (_) {
//       _fetchAppointments();
//     });
//   }

//   @override
//   void dispose() {
//     _timer.cancel(); // Cancel the timer when the screen is disposed
//     super.dispose();
//   }

//   Future<void> _fetchAppointments() async {
//     try {
//       DatabaseEvent event = await _appointmentsRef
//           .orderByChild('patientId')
//           .equalTo(_currentUserId)
//           .once();

//       print("Fetching appointments for user: $_currentUserId");

//       if (event.snapshot.value != null) {
//         Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;

//         setState(() {
//           _appointments = data.entries
//               .map((entry) => {
//                     'id': entry.key,
//                     'doctorName': entry.value['doctorName'],
//                     'doctorSpecialty': entry.value['doctorSpecialty'],
//                     'doctorImage': entry.value['doctorImage'],
//                     'appointmentDate': entry.value['appointmentDate'],
//                     'appointmentTime': entry.value['appointmentTime'],
//                   })
//               .toList();
//         });

//         print("Appointments Found: $_appointments");
//       } else {
//         print("No appointments found.");
//       }
//     } catch (e) {
//       print("Error fetching appointments: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Request Cancellation",style: TextStyle(color: AppColors.white,fontWeight: FontWeight.bold),),
//         backgroundColor: AppColors.blue,
//       ),
//       body: _appointments.isEmpty
//           ? const Center(child: Text("No appointment history available"))
//           : ListView.builder(
//               padding: const EdgeInsets.all(12),
//               itemCount: _appointments.length,
//               itemBuilder: (context, index) {
//                 return GestureDetector(
//                   onTap: () => _showAppointmentDialog(_appointments[index]),
//                   child: _buildAppointmentCard(_appointments[index]),
//                 );
//               },
//             ),
//     );
//   }

//   Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
//     DateTime appointmentDate = DateFormat('yyyy-MM-dd').parse(appointment['appointmentDate']);
//     DateTime time = _parseTime(appointment['appointmentTime']);

//     String shortDay = DateFormat('E').format(appointmentDate);
//     String formattedDate = DateFormat('MMM dd, yyyy').format(appointmentDate);
//     String formattedTime = DateFormat('hh:mm a').format(time);
//     String period = time.hour < 12 ? 'Morning set' : 'Afternoon set';

//     return Container(
//       width: 350,
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: AppColors.blue,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               CircleAvatar(
//                 radius: 30,
//                 backgroundImage: AssetImage(appointment['doctorImage']),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       appointment['doctorName'],
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.white,
//                         fontSize: 16,
//                       ),
//                     ),
//                     Text(
//                       appointment['doctorSpecialty'],
//                       style: const TextStyle(
//                         fontSize: 12,
//                         color: Colors.white70,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Container(
//                 child:GestureDetector(
//   onTap: () {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ChatScreen(doctorId: '', patientId: '',
//           // doctorId: widget.doctor.id,
//           // patientId: widget.patientName,
//         ),
//       ),
//     );
//   },
//   child: Container(
//     padding: const EdgeInsets.all(10),
//     decoration: BoxDecoration(
//       color: AppColors.white,
//       shape: BoxShape.circle,
//     ),
//     child: const Icon(Icons.message, color: AppColors.black),
//   ),
// ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Container(
//             height: 40,
//             decoration: BoxDecoration(
//               color: const Color.fromARGB(255, 25, 42, 96),
//               borderRadius: BorderRadius.circular(15),
//             ),
//             child: Row(
//               children: [
//                 const SizedBox(width: 10),
//                 const Icon(Icons.calendar_month, color: Colors.white, size: 20),
//                 const SizedBox(width: 5),
//                 Text("$shortDay, $formattedDate",
//                     style: const TextStyle(color: Colors.white, fontSize: 14)),
//                 const SizedBox(width: 10),
//                 const Icon(Icons.access_time, color: Colors.white, size: 20),
//                 const SizedBox(width: 5),
//                 Text("$period, $formattedTime",
//                     style: const TextStyle(color: AppColors.white, fontSize: 14)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showAppointmentDialog(Map<String, dynamic> appointment) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text("Appointment Details"),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text("Doctor: ${appointment['doctorName']}"),
//               Text("Specialty: ${appointment['doctorSpecialty']}"),
//               Text("Date: ${appointment['appointmentDate']}"),
//               Text("Time: ${appointment['appointmentTime']}"),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("OK"),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context); // Close first dialog
//                 _showCancelConfirmation(appointment['id']);
//               },
//               child: const Text("Cancel Booking", style: TextStyle(color: Colors.red)),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showCancelConfirmation(String appointmentId) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text("Cancel Appointment?"),
//           content: Text("Are you sure you want to cancel this appointment?"),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("No"),
//             ),
//             TextButton(
//               onPressed: () => _cancelAppointment(appointmentId),
//               child: const Text("Yes, Cancel", style: TextStyle(color: Colors.red)),
//             ),
//           ],
//         );
//       },
//     );
//   }
// Future<void> _cancelAppointment(String appointmentId) async {
//   try {
//     // Remove the appointment from Firebase
//     await _appointmentsRef.child(appointmentId).remove();

//     // Remove the appointment from the local list
//     setState(() {
//       _appointments.removeWhere((appointment) => appointment['id'] == appointmentId);
//     });

//     Navigator.pop(context); // Close the confirmation dialog
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Appointment cancelled successfully")),
//     );
//   } catch (e) {
//     print("Error cancelling appointment: $e");
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Failed to cancel appointment")),
//     );
//   }
// }

//   // Future<void> _cancelAppointment(String appointmentId) async {
//   //   try {
//   //     await _appointmentsRef.child(appointmentId).remove();
//   //     Navigator.pop(context); // Close confirmation dialog
//   //     _fetchAppointments(); // Refresh list
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(content: Text("Appointment cancelled successfully")),
//   //     );
//   //   } catch (e) {
//   //     print("Error cancelling appointment: $e");
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(content: Text("Failed to cancel appointment")),
//   //     );
//   //   }
//   // }

//   DateTime _parseTime(String timeStr) {
//     return DateFormat('HH:mm').parse(timeStr);
//   }
// }
