import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
//

    // Delay for 3 seconds to simulate a splash screen
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushNamed(context, '/onboarding_screen');

      // if (isFirstLaunch) {
      //   // If it's the first launch, navigate to the OnboardingScreen
      //   Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(builder: (context) => OnboardingScreen()),
      //   );

      //   // Set isFirstLaunch to false for future launches
      //   prefs.setBool('isFirstLaunch', true);
      // } else {
      //   // If it's not the first launch, navigate to the LoginPage
      //   Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(builder: (context) => LoginPage()),
      //   );
      // }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD7D1BE),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              width: 300,
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
