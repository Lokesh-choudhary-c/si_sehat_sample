import 'package:appointment_mgmt_app/consts/images.dart';
import 'package:firebase_database/firebase_database.dart';

class Doctor {
  final String id;
  final String name;
  final String specialty;
  final double rating;
  final String price;
  final String image;
  final String hospital;
  final String workingHours;
  final String biography;
  final String location;
  final List<Review> reviews;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.price,
    required this.image,
    required this.hospital,
    required this.workingHours,
    required this.biography,
    required this.location,
    required this.reviews,
  });

  factory Doctor.fromRTDB(Map<dynamic, dynamic> data) {
    return Doctor(
      id: data['id'] ?? '',
      name: data['name'] ?? 'Unknown',
      specialty: data['specialty'] ?? 'General',
      rating: _parseDouble(data['rating']),
      price: data['price'] ?? '\$0.00',
      image: (data['image'] == "asset") 
          ? AppAssets.imgDoctorImg
          : (data['image'] ?? AppAssets.imgDoctorImg),
      hospital: data['hospital'] ?? '',
      workingHours: data['workingHours'] ?? '',
      biography: data['biography'] ?? '',
      location: data['location'] ?? '',
      reviews: _parseReviews(data['reviews']),
    );
  }

  static List<Review> _parseReviews(dynamic data) {
    if (data != null && data is Map) {
      return data.entries
          .map((entry) => Review.fromRTDB(Map<String, dynamic>.from(entry.value)))
          .toList();
    }
    return [];
  }
}




class Review {
  final String name;
  final String profileImage;
  final double rating;
  final String comment;

  Review({
    required this.name,
    required this.profileImage,
    required this.rating,
    required this.comment,
  });

  factory Review.fromRTDB(Map<dynamic, dynamic> data) {
    return Review(
      name: data['name'] ?? 'Anonymous',
      profileImage: (data['profileImage'] == "asset") 
          ? AppAssets.imgReview 
          : (data['profileImage'] ?? AppAssets.imgReview),
      rating: _parseDouble(data['rating']),
      comment: data['comment'] ?? '',
    );
  }
}


// Helper function to safely parse rating values
double _parseDouble(dynamic value, {double defaultValue = 0.0}) {
  if (value is int) return value.toDouble();
  if (value is double) return value;
  if (value is String) return double.tryParse(value) ?? defaultValue;
  return defaultValue;
}

class DoctorData {
  static final FirebaseDatabase _database = FirebaseDatabase.instance;
  static final String doctorsPath = 'doctors';

  static Future<List<Doctor>> getDoctorsFromRTDB() async {
    final doctorsRef = _database.ref(doctorsPath);
    final snapshot = await doctorsRef.get();

    if (!snapshot.exists || snapshot.value == null) {
      return []; // Return empty list if no data exists
    }

    if (snapshot.value is Map<dynamic, dynamic>) {
      return (snapshot.value as Map<dynamic, dynamic>).entries.map((entry) {
        return Doctor.fromRTDB(Map<String, dynamic>.from(entry.value));
      }).toList();
    }

    return []; // If data format is unexpected, return an empty list
  }

  static Future<void> saveDoctorsToRTDB() async {
    // Placeholder function if needed later
  }
}

class Booking {
  String id;
  String doctorId;
  String patientId;
  String appointmentDate;
  String appointmentTime;
  String status;

  Booking({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.status,
  });

  factory Booking.fromRTDB(Map<dynamic, dynamic> data) {
    return Booking(
      id: data['id'] ?? '',
      doctorId: data['doctorId'] ?? '',
      patientId: data['patientId'] ?? '',
      appointmentDate: data['appointmentDate'] ?? '',
      appointmentTime: data['appointmentTime'] ?? '',
      status: data['status'] ?? 'Pending',
    );
  }
}
