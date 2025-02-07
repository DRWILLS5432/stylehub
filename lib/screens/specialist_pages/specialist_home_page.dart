import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stylehub/constants/app/app_colors.dart';
import 'package:stylehub/constants/app/textstyle.dart';
import 'package:stylehub/screens/specialist_pages/specialist_dashboard.dart';

class SpecialistPage extends StatefulWidget {
  const SpecialistPage({super.key});

  @override
  State<SpecialistPage> createState() => _SpecialistPageState();
}

class _SpecialistPageState extends State<SpecialistPage> {
  int _selectedIndex = 0;

  // Define your pages here
  static final List<Widget> _widgetOptions = <Widget>[
    SpecialistDashboard(),
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
      backgroundColor: AppColors.whiteColor,
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: Container(
        margin: EdgeInsets.all(20.dg),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.dg),
          child: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home, size: 20.h),
                label: 'Home', // Replace with localized strings
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today, size: 20.h),
                label: 'Appointments',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite, size: 20.h),
                label: 'Likes',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today, size: 20.h),
                label: 'Schedule',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: AppColors.mainBlackTextColor,
            unselectedItemColor: Colors.grey,
            onTap: _onItemTapped,
            backgroundColor: AppColors.appBGColor,
            type: BottomNavigationBarType.fixed, // Prevents shifting
            selectedLabelStyle: appTextStyle12K(AppColors.mainBlackTextColor),
          ),
        ),
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
