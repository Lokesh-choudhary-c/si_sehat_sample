import 'package:appointment_mgmt_app/consts/colors.dart';
import 'package:appointment_mgmt_app/consts/images.dart';
import 'package:appointment_mgmt_app/consts/strings.dart';
import 'package:appointment_mgmt_app/screens/book_an_appointment/ent/ear_nose_throat.dart';
import 'package:appointment_mgmt_app/screens/book_an_appointment/see_more.dart';
import 'package:flutter/material.dart';

class AppointmentScreen extends StatefulWidget {
  final String name;

  const AppointmentScreen({super.key, required this.name});

  @override
  // ignore: library_private_types_in_public_api
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, String>> specialties = [];
  List<Map<String, String>> filteredSpecialties = [];

  @override
  void initState() {
    super.initState();

    specialties = [
      {"icon": AppAssets.imgEar, "title": AppString.earNoseAndThroat},
      {"icon": AppAssets.imgPsych, "title": AppString.phsychiatrist},
      {"icon": AppAssets.imgDentist, "title": AppString.dentist},
      {"icon": AppAssets.imgDermato, "title": AppString.dermatoVenereologist},
    ];

    filteredSpecialties = List.from(specialties);
    searchController.addListener(_filterSpecialties);
  }

  void _filterSpecialties() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredSpecialties = specialties
          .where((specialty) =>
              specialty["title"]!.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text(
          AppString.bookAnAppointment,
          style: TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppString.medicalSpecialties,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              AppString.wideSelectionOfDoctorSpecialties,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.grey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: AppColors.black),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            decoration: const InputDecoration(
                              hintText: AppString.symptomsDiseases,
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.darkGrey),
                  ),
                  child: const Icon(Icons.filter_list, color: AppColors.blue),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (filteredSpecialties.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    "No specialties found.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: filteredSpecialties.length + 1, 
                  itemBuilder: (context, index) {
                    if (index == filteredSpecialties.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => SeeMore(),));
                              },
                              child: const Text(
                                'See More',
                                style: TextStyle(
                                  color: AppColors.blue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, color: AppColors.blue, size: 16),
                          ],
                        ),
                      );
                    }

                    var specialty = filteredSpecialties[index];
                    return _buildSpecialtyCard(
                      iconPath: specialty["icon"]!,
                      title: specialty["title"]!,
                      subtitle: AppString.wideSelectionOfDoctorSpecialties,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EarNoseThroat(name: widget.name),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialtyCard({
    required String iconPath,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.grey,
                borderRadius: BorderRadius.circular(45),
              ),
              child: Image.asset(iconPath, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.blue),
          ],
        ),
      ),
    );
  }
}
