// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:appointment_mgmt_app/consts/colors.dart';
import 'package:appointment_mgmt_app/consts/images.dart';
import 'package:appointment_mgmt_app/res/models/doctors.dart';
import 'package:appointment_mgmt_app/screens/book_an_appointment/ent/confirm.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class PaymentScreen extends StatefulWidget {
  final Doctor doctor;
  final String appointmentDate;
  final String appointmentTime;

  const PaymentScreen({
    super.key,
    required this.doctor,
    required this.appointmentDate,
    required this.appointmentTime,
  });

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _selectedPaymentMethod; // Selected Payment Method
  String _patientName = "Unknown"; // Default if not fetched

  @override
  void initState() {
    super.initState();
    _fetchPatientName();
  }

  Future<void> _fetchPatientName() async {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _patientName = user.displayName ?? "Unknown";
      });
    }
  }

  Future<void> _makePayment() async {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method.')),
      );
      return;
    }

    final bookingRef = _database.ref().child('bookings');
    final newBookingKey = bookingRef.push().key;

    await bookingRef.child(newBookingKey!).set({
      'id': newBookingKey,
      'doctorId': widget.doctor.id,
      'doctorName': widget.doctor.name,
      'specialty': widget.doctor.specialty,
      'appointmentDate': widget.appointmentDate,
      'appointmentTime': widget.appointmentTime,
      'paymentMethod': _selectedPaymentMethod,
      'status': 'paid',
      'patientName': _patientName, 
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmationScreen(
          doctorName: widget.doctor.name,
          specialty: widget.doctor.specialty,
          appointmentDate: "${widget.appointmentDate}, ${widget.appointmentTime}",
          doctorImage: widget.doctor.image,
          patientName: _patientName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(widget.doctor.image),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < widget.doctor.rating.floor()
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.orange,
                          size: 16,
                        ),
                      ),
                    ),
                    Text(
                      widget.doctor.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(widget.doctor.specialty,
                        style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Schedule Date", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            ListTile(
              leading: SizedBox(
                  height: 50, width: 50, child: Image.asset(AppAssets.icBookAppointment)),
              title: const Text("Appointment"),
              subtitle: Text(
                "${widget.appointmentDate}, ${widget.appointmentTime}",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.black),
              ),
            ),
            const SizedBox(height: 10),
            Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text("Select Payment Method", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            
            _buildPaymentOption("Credit Card", 'assets/images/credit card logo.jpg'),
            SizedBox(height: 5,),
            _buildPaymentOption("PayPal", 'assets/images/paypal logo.png'),
             SizedBox(height: 5,),
            _buildPaymentOption("Google Pay", 'assets/images/gpay_removebg.png'),
             SizedBox(height: 5,),
            _buildPaymentOption("Bank Transfer",'assets/images/bank transfer logo.jpg'),
            const SizedBox(height: 20),
            Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text("Total Payment", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            ListTile(
              title: const Text("Consultation Fee"),
              trailing: Text(widget.doctor.price, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.black)),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Total", style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 10),
                    Text(widget.doctor.price, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.black)),
                  ],
                ),
                ElevatedButton(
                  onPressed: _makePayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Pay", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String method, String icon) {
    return RadioListTile(
      value: method,
      groupValue: _selectedPaymentMethod,
      onChanged: (String? value) {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      title: Text(method),
      secondary: Image.asset(icon, width: 40),
      activeColor: AppColors.blue,
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }
}

