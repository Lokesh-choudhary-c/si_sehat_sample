import 'package:flutter/material.dart';

class SeeMore extends StatelessWidget {
  const SeeMore({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> doctorTypes = [
      {"name": "Cardiologist", "icon": "assets/icons/Fatured icon.png"},
      {"name": "Pediatrician", "icon": "assets/icons/Fatured icon.png"},
      {"name": "Orthopedic", "icon": "assets/icons/Fatured icon.png"},
      {"name": "Neurologist", "icon": "assets/icons/Fatured icon.png"},
      {"name": "Ophthalmologist", "icon": "assets/icons/Fatured icon.png"},
      {"name": "Gynecologist", "icon": "assets/icons/Fatured icon.png"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctor Specialties"),
        backgroundColor: Colors.blue,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: doctorTypes.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          return ListTile(
            leading: Image.asset(doctorTypes[index]['icon']!, width: 30, height: 30),
            title: Text(
              doctorTypes[index]['name']!,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            onTap: () {},
          );
        },
      ),
    );
  }
}
