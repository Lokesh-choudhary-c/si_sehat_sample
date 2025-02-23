import 'package:firebase_database/firebase_database.dart';

class AppointmentMonitor {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  void startMonitoring() {
    _database.ref('appointments').onChildChanged.listen((event) {
      _checkAppointmentQueueStatus(event.snapshot);
      _checkAppointmentReminder(event.snapshot);
    });
  }

  void _checkAppointmentQueueStatus(DataSnapshot snapshot) {
    int queueNumber = snapshot.child('queueNumber').value as int;
    if (queueNumber < 5) {
      _sendQueueStatusNotification(queueNumber);
    }
  }

  void _checkAppointmentReminder(DataSnapshot snapshot) {
    int appointmentTime = snapshot.child('appointmentTime').value as int;
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    if (appointmentTime - currentTime <= 24 * 60 * 60 * 1000) {
      _sendAppointmentReminderNotification(appointmentTime);
    }
  }

  void _sendQueueStatusNotification(int queueNumber) {
  }

  void _sendAppointmentReminderNotification(int appointmentTime) {
  }
}
