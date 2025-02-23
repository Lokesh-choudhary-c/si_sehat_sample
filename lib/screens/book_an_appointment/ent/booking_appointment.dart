
// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api, use_build_context_synchronously

import 'package:appointment_mgmt_app/consts/colors.dart';
import 'package:appointment_mgmt_app/screens/book_an_appointment/ent/payment.dart';
import 'package:appointment_mgmt_app/screens/calender_screen/calender_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:appointment_mgmt_app/res/models/doctors.dart';

class AppointmentBookingScreen extends StatefulWidget {
  final Doctor doctor;

  const AppointmentBookingScreen({super.key, required this.doctor, required String patientName});

  @override
  _AppointmentBookingScreenState createState() => _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  final userId = FirebaseAuth.instance.currentUser?.uid;

  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;

  final List<String> _morningSlots = ["10:00", "11:00", "12:00","13:00"];
  final List<String> _afternoonSlots = ["17:00", "18:00", "19:00", "20:00"];

  List<String> _bookedSlots = [];

  @override
  void initState() {
    super.initState();
    _fetchBookedSlots();
  }

  Future<void> _fetchBookedSlots() async {
    String dateKey = DateFormat('yyyy-MM-dd').format(_selectedDate);
    DatabaseReference ref = FirebaseDatabase.instance.ref().child('appointments');
    DatabaseEvent event = await ref.orderByChild('appointmentDate').equalTo(dateKey).once();
    
    List<String> bookedTimes = [];
    if (event.snapshot.value != null) {
      Map<dynamic, dynamic> appointments = event.snapshot.value as Map<dynamic, dynamic>;
      appointments.forEach((key, value) {
        bookedTimes.add(value['appointmentTime']);
      });
    }

    setState(() {
      _bookedSlots = bookedTimes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Make Appointment"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CalenderScreen()),
              );
            },
            icon: Icon(Icons.calendar_today_outlined),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select your visit date & Time",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 5),
            const Text(
              "You can choose the date and time from the available doctor's schedule",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 15),
            _buildMonthSelection(),
            const SizedBox(height: 20),
            _buildScrollableCalendar(),
            const SizedBox(height: 20),
            _buildTimeSelection(),
            const Spacer(),
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelection() {
    return Text(
      "Choose Day, ${DateFormat('MMM yyyy').format(_selectedDate)}",
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    );
  }

  Widget _buildScrollableCalendar() {
    DateTime now = DateTime.now();
    DateTime firstDay = DateTime(now.year, now.month, now.day);
    DateTime lastDay = DateTime(now.year, now.month + 1, 0);

    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: lastDay.difference(firstDay).inDays + 1,
        itemBuilder: (context, index) {
          DateTime date = firstDay.add(Duration(days: index));
          bool isSelected = isSameDay(_selectedDate, date);

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
              _fetchBookedSlots();
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.blue : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey),
              ),
              child: Column(
                children: [
                  Text(
                    DateFormat.E().format(date),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTimeRow("Morning Set", _morningSlots),
        const SizedBox(height: 15),
        _buildTimeRow("Afternoon Set", _afternoonSlots),
      ],
    );
  }
  Widget _buildTimeRow(String title, List<String> timeSlots) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: timeSlots.map((time) {
          bool isSelected = _selectedTime == time;
          bool isBooked = _bookedSlots.contains(time);

          return GestureDetector(
            onTap: isBooked
                ? null
                : () {
                    setState(() {
                      _selectedTime = time;
                    });
                  },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isBooked
                    ? Colors.grey.shade300
                    : isSelected
                        ? AppColors.blue
                        : Colors.white,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                time,
                style: TextStyle(
                  color: isBooked ? Colors.grey : (isSelected ? Colors.white : Colors.black),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ],
  );
}
  Widget _buildConfirmButton() {
    return Center(
      child: ElevatedButton(
        onPressed: (_selectedTime == null)
            ? null
            : () async {
                try {
                  await FirebaseDatabase.instance.ref().child('appointments').push().set({
                    'doctorId': widget.doctor.id,
                    'doctorName': widget.doctor.name,
                    'doctorSpecialty': widget.doctor.specialty,
                    'doctorRating': widget.doctor.rating,
                    'doctorPrice': widget.doctor.price,
                    'doctorImage': widget.doctor.image,
                    'doctorHospital': widget.doctor.hospital,
                    'doctorWorkingHours': widget.doctor.workingHours,
                    'doctorBiography': widget.doctor.biography,
                    'doctorLocation': widget.doctor.location,
                    'appointmentDate': DateFormat('yyyy-MM-dd').format(_selectedDate),
                    'appointmentTime': _selectedTime,
                    'patientId': userId, 
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentScreen(
                        doctor: widget.doctor,
                        appointmentDate: DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
                        appointmentTime: _selectedTime!,
                      ),
                    ),
                  );
                } catch (e) {
                  // ignore: avoid_print
                  print("Error saving appointment: $e");
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedTime == null ? Colors.grey : AppColors.blue,
          padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          minimumSize: Size(double.infinity, 50),
        ),
        child: const Text("Confirm", style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }
}

bool isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
}
