import 'package:appointment_mgmt_app/consts/colors.dart';
import 'package:appointment_mgmt_app/res/models/doctors.dart';
import 'package:appointment_mgmt_app/res/services/db_service/rt.dart';
import 'package:appointment_mgmt_app/screens/book_an_appointment/ent/booking_appointment.dart';
import 'package:appointment_mgmt_app/screens/chat_screen/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class DoctorsAppointment extends StatefulWidget {
  final Doctor doctor;
  final String patientName; 

  const DoctorsAppointment({
    super.key,
    required this.doctor,
    required this.patientName,
  });

  @override
  State<DoctorsAppointment> createState() => _DoctorsAppointmentState();
}

class _DoctorsAppointmentState extends State<DoctorsAppointment> {
  final RealtimeDatabaseService _databaseService = RealtimeDatabaseService();
  List<Review> _reviews = [];

  @override
  void initState() {
    super.initState();
    _retrieveReviews();
  }

  Future<void> _retrieveReviews() async {
    String path = 'doctors/doctor${widget.doctor.id}/reviews';
    final reviewsData = await _databaseService.readData(path);

    if (reviewsData != null) {
      setState(() {
        _reviews = (reviewsData as Map).values
            .map((reviewData) => Review.fromRTDB(reviewData))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.black),
        title: Text(
          widget.doctor.specialty,
          style: const TextStyle(color: AppColors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListView(
          children: [
            _buildDoctorInfo(),
            Divider(),
            _buildBiography(),
            Divider(),
            _buildWorkLocation(),
            Divider(),
            _buildRatings(),
            Divider(),
            _buildAppointmentButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage(widget.doctor.image),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.doctor.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.black)),
                  Text(widget.doctor.specialty, style: TextStyle(fontSize: 14, color: AppColors.grey)),
                  const SizedBox(height: 4),
                  // ignore: unnecessary_string_interpolations
                  Text("${widget.doctor.price}",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.black)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 18.0, bottom: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.local_hospital, color: Colors.red, size: 18),
                      const SizedBox(width: 5),
                      Text("Hospital", style: TextStyle(color: AppColors.grey)),
                    ],
                  ),
                  Text(widget.doctor.hospital,
                      style: const TextStyle(fontSize: 20, color: AppColors.black, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(right: 18.0, bottom: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.access_time_filled_sharp, color: AppColors.blue, size: 18),
                      Text(" Working Hour", style: TextStyle(color: AppColors.grey)),
                    ],
                  ),
                  Text(widget.doctor.workingHours,
                      style: const TextStyle(fontSize: 20, color: AppColors.black, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBiography() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Biography", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 4),
        Text(widget.doctor.biography, style: const TextStyle(fontSize: 14, color: AppColors.black)),
      ],
    );
  }

  Widget _buildWorkLocation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Work Location", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 4),
        Text(widget.doctor.location, style: const TextStyle(fontSize: 14, color: AppColors.black)),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(-6.2088, 106.8456),
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png"),
              MarkerLayer(
                markers: [
                  Marker(
                    width: 40.0,
                    height: 40.0,
                    point: LatLng(-6.2088, 106.8456),
                    child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRatings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text("Ratings & Reviews", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Spacer(),
            const Icon(Icons.star, color: Colors.orange, size: 18),
            Text(widget.doctor.rating.toString(), style: const TextStyle(fontSize: 14)),
          ],
        ),
        const SizedBox(height: 8),
        _reviews.isEmpty
            ? const Text("No reviews available.", style: TextStyle(color: Colors.grey))
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _reviews.length,
                itemBuilder: (context, index) {
                  final review = _reviews[index];
                  return ListTile(
                    leading: CircleAvatar(backgroundImage: AssetImage(review.profileImage)),
                    title: Text(review.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text(review.comment, style: const TextStyle(fontSize: 12)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 18, color: Colors.orange),
                        Text(review.rating.toString()),
                      ],
                    ),
                  );
                },
              ),
      ],
    );
  }
    Widget _buildAppointmentButton(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AppointmentBookingScreen(doctor: widget.doctor,patientName: widget.patientName,),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text("Make Appointment", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
          
        ),
         const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
        doctorId: widget.doctor.id,
        patientId: widget.patientName, 
                ),
              ),
            );
          },
               child: Container(
                 padding: const EdgeInsets.all(10),
                 decoration: BoxDecoration(
                 color: AppColors.blue.withOpacity(0.1),
                 shape: BoxShape.circle,
                 ),
                 child: const Icon(Icons.message, color: AppColors.black),
         ),
        ),
      ],
    );
  }
}
