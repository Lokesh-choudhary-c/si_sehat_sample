// ignore_for_file: library_private_types_in_public_api

import 'package:appointment_mgmt_app/consts/colors.dart';
import 'package:appointment_mgmt_app/consts/images.dart';
import 'package:appointment_mgmt_app/consts/strings.dart';
import 'package:appointment_mgmt_app/screens/qr_appointment/scanning_screen.dart';
import 'package:flutter/material.dart';

class AppointmentWithQRScreen extends StatefulWidget {
  final String name; 
  const AppointmentWithQRScreen({super.key, required this.name});
  
  @override
  _AppointmentWithQRScreenState createState() => _AppointmentWithQRScreenState();
}

class _AppointmentWithQRScreenState extends State<AppointmentWithQRScreen> {
  String selectedSpecialist = '';  
  final TextEditingController nameController = TextEditingController();
  final TextEditingController symptomsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Appointment With QR"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Make An appointment with QR",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  AppString.wideSelectionOfDoctorSpecialties,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                SizedBox(height: 16),
                Text("Full Name",style: TextStyle(fontWeight: FontWeight.bold),),
                SizedBox(height: 5),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: "Full Name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Specialist",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16)),
                    TextButton(
                      onPressed: () {},
                      child: Text("See All",style: TextStyle(fontWeight: FontWeight.bold,color: AppColors.blue,fontSize: 16)),
                    ),
                  ],
                ),
                _buildSpecialistOptions(),
                SizedBox(height: 16),
                Text("Symptoms",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: AppColors.black),),
                SizedBox(height: 5,),
                TextFormField(
                  controller: symptomsController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your symptoms';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 5,),
                Divider(),
                SizedBox(height: 5),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (selectedSpecialist.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please select a specialist')),
                        );
                      } else {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => QRScannerScreen(name: widget.name,),));
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: AppColors.blue,
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text(
                    "Scan With QR",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialistOptions() {
    final specialists = [
      {"icon": AppAssets.imgEar, "label": "Ear, Nose & Throat"},
      {"icon": AppAssets.imgDermato, "label": "Dermato-venereologis"},
      {"icon": AppAssets.imgDentist, "label": "Dentist"},
      {"icon": AppAssets.imgPsych, "label": "Psychiatrist"},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: specialists.length,
      itemBuilder: (context, index) {
        final specialist = specialists[index];
        final isSelected = selectedSpecialist == specialist["label"];

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedSpecialist = specialist["label"]!;
                          });
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: isSelected ? AppColors.blue : AppColors.grey),
              borderRadius: BorderRadius.circular(8),
              color: isSelected ? AppColors.blue.withOpacity(0.1) : AppColors.white,
            ),
            padding: EdgeInsets.all(8),
            child: Stack(
              alignment: Alignment.topRight,  
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,  
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          specialist["icon"]!,
                          height: 50,
                          width: 50,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      specialist["label"]!,
                      style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (isSelected)
                  Icon(Icons.radio_button_checked, color: AppColors.blue)
                else
                  Icon(Icons.radio_button_unchecked, color: AppColors.grey),
              ],
            ),
          ),
        );
      },
    );
  }
}












