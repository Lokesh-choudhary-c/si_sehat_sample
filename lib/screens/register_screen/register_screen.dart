// ignore_for_file: use_build_context_synchronously

import 'package:appointment_mgmt_app/consts/colors.dart';
import 'package:appointment_mgmt_app/consts/strings.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool isSignUpEnabled = false;
  bool isLoading = false;
  String passwordStrengthText = "Weak";
  String _email = '';

  @override
  void initState() {
    super.initState();
    _email = FirebaseAuth.instance.currentUser?.email ?? '';
    _passwordController.addListener(validateForm);
    _confirmPasswordController.addListener(validateForm);
    _fullNameController.addListener(validateForm);
  }

  void validateForm() {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      if (password.length >= 8 &&
          RegExp(r'[A-Z]').hasMatch(password) &&
          RegExp(r'[0-9]').hasMatch(password) &&
          RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
        passwordStrengthText = "Strong";
      } else if (password.length >= 6 &&
          RegExp(r'[A-Z]').hasMatch(password) &&
          RegExp(r'[0-9]').hasMatch(password)) {
        passwordStrengthText = "Moderate";
      } else {
        passwordStrengthText = "Weak";
      }

      isSignUpEnabled = password == confirmPassword &&
          passwordStrengthText == "Strong" &&
          _fullNameController.text.isNotEmpty;
    });
  }

  Widget passwordStrengthIndicator() {
    final password = _passwordController.text;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          passwordStrengthText,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: passwordStrengthText == "Strong"
                ? Colors.green
                : passwordStrengthText == "Moderate"
                    ? Colors.orange
                    : Colors.red,
          ),
        ),
        Row(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: password.length >= 8 ? Colors.green : AppColors.grey,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: RegExp(r'[A-Z]').hasMatch(password)
                    ? Colors.green
                    : AppColors.grey,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: RegExp(r'[0-9]').hasMatch(password)
                    ? Colors.green
                    : AppColors.grey,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _updateUserProfile() async {
    try {
      await FirebaseAuth.instance.currentUser?.updateProfile(displayName: _fullNameController.text);
      await FirebaseAuth.instance.currentUser?.updatePassword(_passwordController.text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    }
  }

  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      await _updateUserProfile();
      Navigator.pushReplacementNamed(
        context,
        '/welcome',
        arguments: _fullNameController.text, 
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AppString.register,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(AppString.pleaseEnterAFormToContinueTheRegister,
                  style: TextStyle(fontSize: 16, color: AppColors.black),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    labelText: AppString.fullName,
                    hintText: AppString.enterYourFullName,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  initialValue: _email,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: AppString.email,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: AppString.password,
                    hintText: AppString.enterYourPassword,
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                passwordStrengthIndicator(),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    labelText: AppString.confirmPassword,
                    hintText: AppString.confirmYourPassword,
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(isConfirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          isConfirmPasswordVisible = !isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your confirm password';
                    } else if (value != _passwordController.text) {
                      return 'Password and confirm password do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: isSignUpEnabled && !isLoading ? _register : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    disabledBackgroundColor: AppColors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          'Sign up',
                          style: TextStyle(fontSize: 16, color: AppColors.white),
                        ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                         onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                        },
                        child:  RichText(
                          text: TextSpan( text:  AppString.alreadyHaveAnAccount,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.black,
                          ),
                          children: [
                            TextSpan(
                              text: AppString.signIn,
                              style: TextStyle(
                                color: AppColors.blue,
                                fontSize: 14,
                                fontWeight: FontWeight.bold
                              )
                            )
                          ]
                          )
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}