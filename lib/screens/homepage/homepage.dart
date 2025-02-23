// ignore_for_file: depend_on_referenced_packages, empty_catches

import 'package:appointment_mgmt_app/consts/colors.dart';
import 'package:appointment_mgmt_app/consts/images.dart';
import 'package:appointment_mgmt_app/consts/strings.dart';
import 'package:appointment_mgmt_app/screens/book_an_appointment/book_an_appointment.dart';
import 'package:appointment_mgmt_app/screens/chat_screen/chat_screen.dart';
import 'package:appointment_mgmt_app/screens/locate_pharmacy/locate_pharmacy.dart';
import 'package:appointment_mgmt_app/screens/qr_appointment/qr_appt.dart';
import 'package:appointment_mgmt_app/screens/qr_appointment/qrapptdetails.dart';
import 'package:appointment_mgmt_app/screens/request_cancellation/request_cancellation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';


class HomepageScreen extends StatefulWidget {
  final String name;

  const HomepageScreen({super.key, required this.name});

  @override
  State<HomepageScreen> createState() => _HomepageScreenState();
}


class _HomepageScreenState extends State<HomepageScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> _appointments = [];
  Map<String, dynamic>? _queueDetails; 
  String _searchText = '';

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _sendNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'appointment_channel', 'Appointment Notifications',
      importance: Importance.high, priority: Priority.high, showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }


void _fetchAppointments() async {
  String userId = _auth.currentUser?.uid ?? "";
  if (userId.isEmpty) return;

  DatabaseEvent event = await _database.child('appointments').once();
  Map<dynamic, dynamic>? data = event.snapshot.value as Map?;

  if (data != null) {
    List<Map<String, dynamic>> fetchedAppointments = [];
    Map<String, dynamic>? queueData;

    data.forEach((key, value) {
      if (value is Map<dynamic, dynamic>) {
        Map<String, dynamic> appointment = Map<String, dynamic>.from(value);
        appointment['id'] = key;
        if (appointment.containsKey('patientId') && appointment['patientId'] == userId) {
          if (appointment.containsKey('appointmentDate') && appointment['appointmentDate'] is String) {
            try {
              DateFormat('yyyy-MM-dd').parse(appointment['appointmentDate']);
              fetchedAppointments.add(appointment);
            } catch (e) {
            }
          } else {
          }
        }
        if (appointment.containsKey('queueSystem') &&
            appointment['queueSystem']['isActive'] == true &&
            appointment['patientId'] == userId) {
          queueData = appointment;
        }
      }
    });
    fetchedAppointments.sort((a, b) {
      try {
        DateTime dateA = DateFormat('yyyy-MM-dd').parse(a['appointmentDate']);
        DateTime dateB = DateFormat('yyyy-MM-dd').parse(b['appointmentDate']);
        DateTime timeA = _parseTime(a['appointmentTime']);
        DateTime timeB = _parseTime(b['appointmentTime']);

        if (dateA == dateB) {
          return timeA.compareTo(timeB);
        }
        return dateA.compareTo(dateB);
      } catch (e) {
        return 0;
      }
    });

    setState(() {
      _appointments = fetchedAppointments;
      _queueDetails = queueData;
    });

    _checkNotifications();
  }
}

  void _checkNotifications() {
    if (_queueDetails != null) {

      int queueNumber = _queueDetails!['queueSystem']['queueNumber'] ?? 0;
      if (queueNumber < 5) {
        _sendNotification(
          'Queue Status: Your turn is approaching!',
          'You are in the queue for your appointment. Your current queue number is $queueNumber.',
        );
      }
    }
    for (var appointment in _appointments) {
      DateTime appointmentDate = DateFormat('yyyy-MM-dd').parse(appointment['appointmentDate'] ?? '');
      DateTime appointmentTime = _parseTime(appointment['appointmentTime'] ?? '');
      DateTime appointmentDateTime = DateTime(
        appointmentDate.year,
        appointmentDate.month,
        appointmentDate.day,
        appointmentTime.hour,
        appointmentTime.minute,
      );

      Duration difference = appointmentDateTime.difference(DateTime.now());
      if (difference.inHours == 24 || difference.inHours == 4 || difference.inHours == 2 || difference.inHours == 1) {
        _sendNotification(
          'Appointment Reminder',
          'You have an appointment with Dr. ${appointment['doctorName']} on ${DateFormat('MMM dd, yyyy').format(appointmentDate)} at ${DateFormat('HH:mm').format(appointmentTime)}.',
        );
      }
    }
  }

  DateTime _parseTime(String time) {
    try {
      return DateFormat('HH:mm').parse(time);
    } catch (e) {
      return DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: AppColors.white,
        title: Padding(
          padding:  EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Text(
                'Hi ${widget.name}!',
                style: const TextStyle(
                  color: AppColors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                AppString.mayYouAlwaysInAGoodCondition,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppColors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding:  EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding:  EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search, color: Colors.black54),
                            SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                onChanged: (text) {
                                  setState(() {
                                    _searchText = text.toLowerCase();
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: AppString.symptomsDiseases,
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                     SizedBox(width: 8),
                    Container(
                      padding:  EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.filter_alt, color: AppColors.blue),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (_queueDetails != null || _appointments.isNotEmpty) _buildAppointmentBar(),
                const SizedBox(height: 16),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildMainContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

Widget _buildQueueCard() {
  if (_queueDetails == null || _queueDetails!['patientId'] != _auth.currentUser?.uid) {
    return SizedBox.shrink();
  }

  int queueNumber = _queueDetails!['queueSystem']['queueNumber'] ?? 0;
  int totalQueue = _queueDetails!['queueSystem']['totalQueue'] ?? queueNumber;
  int queueLeft = (totalQueue - queueNumber).clamp(0, totalQueue);
  double progress = 1 - (queueLeft / totalQueue).clamp(0.0, 1.0);

  return Container(
    width: 350,
    margin: const EdgeInsets.only(right: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.blue,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: const DecorationImage(
                  image: AssetImage("assets/icons/qrsuccess.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Queue Number",
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(
                        height: 35,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QrApptDetails(
                                  name: widget.name,
                                  appointmentDetails: _queueDetails,
                                ),
                              ),
                            );
                          },
                          child: Text(
                            "See Details >",
                            style: TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    queueNumber.toString(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 14, 44, 141)),
              minHeight: 10,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 5),
            Text(
              "Remaining $queueLeft queue",
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ],
    ),
  );
}


Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
  DateTime appointmentDate = DateFormat('yyyy-MM-dd').parse(appointment['appointmentDate'] ?? '');
  DateTime time = _parseTime(appointment['appointmentTime'] ?? '');

  String shortDay = DateFormat('E').format(appointmentDate); 
  String formattedDate = DateFormat('MMM dd, yyyy').format(appointmentDate); 
  String formattedTime = DateFormat('HH:mm').format(time); 
  String period = time.hour < 12 ? 'Morning set' : 'Afternoon set'; 

  return Container(
    width: 350, 
    margin: const EdgeInsets.only(right: 12),
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
                    appointment['doctorName'] ?? 'Unknown Doctor',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    appointment['doctorSpecialty'] ?? 'Unknown Specialty',
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
               Navigator.push(context,MaterialPageRoute(builder: (context) => ChatScreen(doctorId: '', patientId: '',),),);
               },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
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

  Widget _buildAppointmentBar() {
    List<Widget> appointmentCards = [];

    if (_queueDetails != null) {
      appointmentCards.add(_buildQueueCard());
    }

    if (_searchText.isEmpty) {
      appointmentCards.addAll(_appointments.map((appointment) => _buildAppointmentCard(appointment)).toList());
    } else {
      appointmentCards.addAll(_appointments
        .where((appointment) => appointment['doctorName'].toLowerCase().contains(_searchText) || appointment['doctorSpecialty'].toLowerCase().contains(_searchText))
        .map((appointment) => _buildAppointmentCard(appointment))
        .toList());
    }

    return SizedBox(
      height: 150, 
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: appointmentCards,
      ),
    );
  }


  Widget _buildMainContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          shrinkWrap: true,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            _buildActionCard(
               color: const Color.fromARGB(255, 246, 233, 250),
              imagePath: AppAssets.icBookAppointment,
              title: 'Book An \nAppointment',
              subtitle: AppString.findADoctorOrSpecialist,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AppointmentScreen(name: widget.name,))),
            ),
             _buildActionCard(
                    color: const Color.fromARGB(255, 224, 253, 226),
                    imagePath: AppAssets.icScanner,
                    title: AppString.appointmentWithQR,
                    subtitle: AppString.queuingWithoutTheHustle,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AppointmentWithQRScreen(name: widget.name,))),
                  ),
                  _buildActionCard(
                    color: const Color.fromARGB(255, 254, 242, 222),
                    imagePath: AppAssets.icRequest,
                    title: AppString.requestConsultation,
                    subtitle:AppString.talkToSpecialist,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RequestCancellation())),
                  ),
                  _buildActionCard(
                    color: const Color.fromARGB(255, 252, 226, 235),
                    imagePath: AppAssets.icLocatePharmacy,
                    title: AppString.locateAPharmacy,
                    subtitle: AppString.purchaseMedicines,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => NearbyPharmaciesScreen())),
                  ),
                ],
              ),
               const SizedBox(height: 10),
              SizedBox(
                height: 150,
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildBannerCard(imagePath: AppAssets.imgBlueCard),
                    const SizedBox(width: 16),
                    _buildBannerCard(imagePath: AppAssets.imgRedCard),
                  ],
                ),
              ), 
      ],
    );
  }

  Widget _buildActionCard({
    required Color color,
    required String imagePath,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:  EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(imagePath, height: 50, fit: BoxFit.cover),
             SizedBox(height: 5),
            Text(title, style:  TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20)),
             SizedBox(height: 4),
            Text(subtitle, style: TextStyle(color: Colors.black54, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

  Widget _buildBannerCard({required String imagePath}) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
