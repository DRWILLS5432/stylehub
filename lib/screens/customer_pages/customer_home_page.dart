import 'package:flutter/material.dart';
import 'package:stylehub/constants/app/app_colors.dart';
import 'package:stylehub/constants/app/textstyle.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  int _selectedIndex = 0;

  // Define your pages here
  static final List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(),
    SearchScreen(),
    BookingScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBGColor,
      appBar: AppBar(
        backgroundColor: AppColors.appBGColor,
        title: Text(
          'StyleHub', // Replace with your app name or localized string
          style: appTextStyle19(AppColors.mainBlackTextColor),
        ),
        centerTitle: true,
        elevation: 0, // Remove shadow
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home', // Replace with localized strings
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online),
            label: 'Booking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.mainBlackTextColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        backgroundColor: Colors.white, // Optional: set background color
        type: BottomNavigationBarType.fixed, // Prevents shifting
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w500), // Optional: style selected label
      ),
    );
  }
}

// Define placeholder screens
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Dashboard Content', style: appTextStyle14(AppColors.mainBlackTextColor)),
    );
  }
}

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Search Content', style: appTextStyle16(AppColors.mainBlackTextColor)),
    );
  }
}

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Booking Content', style: appTextStyle16(AppColors.mainBlackTextColor)),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Profile Content', style: appTextStyle16(AppColors.mainBlackTextColor)),
    );
  }
}
