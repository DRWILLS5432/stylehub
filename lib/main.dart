import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'login_page.dart'; // Создайте этот файл для экрана авторизации

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My App',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: SplashScreenWrapper(),
    );
  }
}

// Обертка для SplashScreen с переходом на LoginPage
class SplashScreenWrapper extends StatefulWidget {
  @override
  _SplashScreenWrapperState createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  @override
  void initState() {
    super.initState();
    // Переход на экран LoginPage через 3 секунды
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen(); // Отображаем сам SplashScreen
  }
}
