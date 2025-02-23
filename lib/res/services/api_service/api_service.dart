// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class ApiService {
//   static const String baseUrl = "http://:5000/api/doctors";

//   // Fetch all doctors
//   static Future<List<dynamic>> getDoctors() async {
//     try {
//       final response = await http.get(Uri.parse(baseUrl));

//       if (response.statusCode == 200) {
//         return json.decode(response.body);
//       } else {
//         throw Exception("Failed to load doctors");
//       }
//     } catch (e) {
//       throw Exception("Error: $e");
//     }
//   }
// }
