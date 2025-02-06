import 'package:flutter/material.dart';
import 'package:stylehub/login_page.dart';
import 'package:stylehub/onboarding_page/onboarding_screen.dart';
import 'package:stylehub/splash_screen.dart';

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  // To Extract the route name from settings
  final routeName = settings.name;

  // Define a map of routes and their corresponding widgets
  final routes = {
    '/': (context) => SplashScreen(),
    '/onboarding_screen': (context) => OnboardingScreen(),
    '/login_screen': (context) => LoginPage(),
  };

  // Check if the requested route is in the routes map
  final builder = routes[routeName];

  // If the route is found, return the corresponding widget
  if (builder != null) {
    return MaterialPageRoute(
      builder: builder,
      settings: settings,
    );
  }
  // If the route is not found, you can handle it with a default page or error page
  return MaterialPageRoute(
    builder: (context) => const ErrorPage(), // Create a DefaultPage widget
    settings: settings,
  );
}

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Back",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              )),
          const SizedBox(width: 40),
          const Text("Error"),
        ],
      ),
    );
  }
}
