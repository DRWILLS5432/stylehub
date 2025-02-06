import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stylehub/constants/app/app_colors.dart';
import 'package:stylehub/constants/localization/locales.dart';
import 'package:stylehub/constants/textstyle.dart';
import 'package:stylehub/onboarding_page/pages/onboarding_page_one.dart';
import 'package:stylehub/onboarding_page/pages/onboarding_page_three.dart';
import 'package:stylehub/onboarding_page/pages/onboarding_page_two.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  final List<Widget> _pages = [
    OnboardingPageOne(),
    OnboardingPageTwo(),
    OnboardingPageThree(),
  ];

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _navigateToNextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
      // Navigate to the home screen or login screen
      // Navigator.pushNamed(context, '/login_screen');
    } else {
      // Navigate to the home screen or login screen
      Navigator.pushNamed(context, '/login_screen');
      print("Get Started clicked!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBGColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: _pages,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildPageIndicator(),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ReusableButton(
                color: _currentPage == _pages.length - 1 ? AppColors.mainBlackTextColor : AppColors.whiteColor,
                text: _currentPage == _pages.length - 1 ? LocaleData.getStarted.getString(context) : LocaleData.next.getString(context),
                onPressed: _navigateToNextPage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPageIndicator() {
    List<Widget> indicators = [];
    for (int i = 0; i < _pages.length; i++) {
      indicators.add(
        Container(
          width: _currentPage == i ? 70.w : 40.w,
          height: 6.h,
          margin: EdgeInsets.symmetric(horizontal: 1.w),
          decoration: BoxDecoration(
            // shape: BoxShape.circle,
            borderRadius: BorderRadius.circular(5.dg),
            color: _currentPage == i ? AppColors.mainBlackTextColor : AppColors.whiteColor,
          ),
        ),
      );
    }
    return indicators;
  }
}

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final String image;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.description,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            image,
            height: 200,
          ),
          SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class ReusableButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;

  const ReusableButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 40.h),
      padding: EdgeInsets.all(3.dg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.dg),
        color: color ?? AppColors.mainBlackTextColor,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.appBGColor,
          minimumSize: Size(double.infinity, 50.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.dg),
          ),
        ),
        child: Text(
          text,
          style: appTextStyle16(AppColors.mainBlackTextColor),
        ),
      ),
    );
  }
}
