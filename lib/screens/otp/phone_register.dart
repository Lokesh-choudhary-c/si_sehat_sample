// ignore_for_file: library_private_types_in_public_api

import 'package:appointment_mgmt_app/consts/colors.dart';
import 'package:appointment_mgmt_app/consts/strings.dart';
import 'package:appointment_mgmt_app/screens/otp/otp_verification.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class PhoneRegister extends StatefulWidget {
  const PhoneRegister({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<PhoneRegister> {
  String? phoneNumber; 
  bool isPhoneNumberValid = false; 
  String hintText = 'e.g. 9876543210';

  final Map<String, String> countryExampleNumbers = {
    'IN': '9876543210',
    'US': '8123456789',
    'GB': '7400123456',
    'AU': '412345678',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Text(
                    AppString.register,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    AppString.pleaseEnterYourNUmberToContinueYourRegistration,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Phone Number',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.black,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  SizedBox(height: 8),
                  IntlPhoneField(
                    decoration: InputDecoration(
                      hintText: hintText, 
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    initialCountryCode: 'IN', 
                    onChanged: (phone) {
                      setState(() {
                        phoneNumber = phone.completeNumber;
                        isPhoneNumberValid = phone.completeNumber.length >= 10;
                      });
                    },
                    onCountryChanged: (country) {
                      setState(() {
                        hintText = countryExampleNumbers[country.code] ?? 'e.g. 123456789';
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            decoration: BoxDecoration(
              color: AppColors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isPhoneNumberValid
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OTPScreen(
                                  phoneNumber: phoneNumber ?? '',
                                ),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPhoneNumberValid
                          ? AppColors.blue
                          : AppColors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        color: isPhoneNumberValid ? Colors.white : Colors.grey,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Center(
                  child: Column(
                    children: [
                      Text(
                        'By signing up or logging in, I accept the app\'s',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              'Terms of Service',
                              style: TextStyle(fontSize: 14, color: AppColors.blue),
                            ),
                          ),
                          Text(
                            ' and ',
                            style: TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              'Privacy Policy',
                              style: TextStyle(fontSize: 14, color: AppColors.blue),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
