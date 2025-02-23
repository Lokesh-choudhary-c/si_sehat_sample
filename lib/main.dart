import 'package:appointment_mgmt_app/consts/colors.dart';
import 'package:appointment_mgmt_app/firebase_options.dart';
import 'package:appointment_mgmt_app/res/models/doctors.dart';
import 'package:appointment_mgmt_app/res/services/notify_service/fetchappt.dart';
import 'package:appointment_mgmt_app/res/services/notify_service/notify_service.dart';
import 'package:appointment_mgmt_app/screens/account_screen/account_screen.dart';
import 'package:appointment_mgmt_app/screens/auth_screen/auth.dart';
import 'package:appointment_mgmt_app/screens/login_screen/login_screen.dart';
import 'package:appointment_mgmt_app/screens/onboarding_screen/onboarding_screen.dart';
import 'package:appointment_mgmt_app/screens/register_screen/register_screen.dart';
import 'package:appointment_mgmt_app/screens/splash_screen/splash_screen.dart';
import 'package:appointment_mgmt_app/screens/welcome_screen/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await DoctorData.saveDoctorsToRTDB(); 
  final notificationService = NotificationService();
  notificationService.initialize();

  AppointmentMonitor appointmentMonitor = AppointmentMonitor();

  appointmentMonitor.startMonitoring();
  await ScreenUtil.ensureScreenSize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Si Sehat',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.blue),
            useMaterial3: true,
          ),
          routes: {
            '/splash': (context) => SplashScreen(),
            '/onboarding': (context) => OnboardingScreen(),
            '/auth': (context) => AuthScreen(),
            '/register': (context) => RegisterScreen(),
            '/welcome': (context) => WelcomeScreen(),
            '/login': (context) => LoginScreen(),
            '/account': (context) => AccountScreen(),
          },
          initialRoute: '/splash',
        );
      },
    );
  }
}
