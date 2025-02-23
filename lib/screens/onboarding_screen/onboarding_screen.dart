import 'package:appointment_mgmt_app/consts/colors.dart';
import 'package:appointment_mgmt_app/consts/images.dart';
import 'package:appointment_mgmt_app/consts/strings.dart';
import 'package:appointment_mgmt_app/screens/auth_screen/auth.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      'image': AppAssets.imgOnboardingOne,
      'title': AppString.welcome,
      'description':AppString.weWillAssistYouInEfficientlyAndEasilySchedulingAppointmentsWithDoctorsLetsGetStarted    
    },
    {
      'image': AppAssets.imgOnboardingTwo,
      'title': AppString.chooseSpecialization,
      'description':AppString.selectTheMedicalSpecializationYouNeedSoWeCanTailorYourExperience,
          
    },
    {
      'image': AppAssets.imgOnboardingThree,
      'title':AppString.scheduleYourFirstAppointment,
      'description':AppString.chooseASuitableTimeAndDateToMeetYourPreferredDoctorBeginYourJourneyToBetterHealth,
          
    },
  ];

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: onboardingData.length,
              itemBuilder: (context, index) {
                final item = onboardingData[index];
                return Image.asset(
                  item['image']!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 24.0, top: 25.0, bottom: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(
                onboardingData.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(right: 8),
                  height: 5,
                  width: _currentPage == index ? 48 : 38,
                  decoration: BoxDecoration(
                    color: _currentPage == index ?AppColors.blue : AppColors.grey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding:  EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:  EdgeInsets.only(top: 8.0),
                        child: Text(
                          onboardingData[_currentPage]['title']!,
                          style:  TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      
                       SizedBox(height: 16),
                      Text(
                        onboardingData[_currentPage]['description']!,
                        style:  TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                     
                      if (_currentPage != onboardingData.length - 1)
                        OutlinedButton(
                          onPressed: () {
                            _pageController.jumpToPage(onboardingData.length - 1);
                          },
                          style: OutlinedButton.styleFrom(
                            side:  BorderSide(color:AppColors.blue, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            minimumSize: Size(MediaQuery.of(context).size.width * 0.4, 48),
                          ),
                          child: const Text(
                            'Skip',
                            style: TextStyle(
                              fontSize: 16,
                              color:AppColors.blue,
                            ),
                          ),
                        ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              if (_currentPage == onboardingData.length - 1) {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => AuthScreen(),));
                              } else {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.blue,
                              foregroundColor:AppColors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side:  BorderSide(color:AppColors.blue, width: 2),
                              ),
                              minimumSize:  Size(double.infinity, 48), 
                            ),
                            child: Text(
                              _currentPage == onboardingData.length - 1
                                  ? AppString.getStarted
                                  : AppString.next,
                              style:  TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
