import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My App',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: SplashScreen(),
    );
  }
}

// // Обертка для SplashScreen с переходом на LoginPage
// class SplashScreenWrapper extends StatefulWidget {
//   @override
//   _SplashScreenWrapperState createState() => _SplashScreenWrapperState();
// }

// class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
//   @override
//   void initState() {
//     super.initState();
//     // Переход на экран LoginPage через 3 секунды
//     Future.delayed(const Duration(seconds: 3), () {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => SplashScreen()),
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SplashScreen(); // Отображаем сам SplashScreen
//   }
// }
