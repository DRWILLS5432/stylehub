import 'package:flutter/material.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stylehub/constants/app/app_colors.dart';
import 'package:stylehub/constants/app/textstyle.dart';
import 'package:stylehub/screens/specialist_pages/screens/appointment_screens/appointment_screen.dart';
import 'package:stylehub/screens/specialist_pages/screens/likes_screens/likes_screen.dart';
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
    AppointmentScreen(),
    LikesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: Padding(
        padding: EdgeInsets.only(bottom: 20.h),
        child: BottomBar(
          barColor: AppColors.appBGColor,
          borderRadius: BorderRadius.circular(20.dg),
          body: (context, scrollController) => _widgetOptions.elementAt(_selectedIndex),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.dg),
              color: AppColors.appBGColor,
            ),
            // margin: EdgeInsets.only(bottom: 20.h, right: 10.w, left: 10.w),
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBarItem(0, 'assets/images/Exterior.png', 'Home'),
                _buildBarItem(1, 'assets/images/Bookmark.png', 'Appointments'),
                _buildBarItem(2, 'assets/images/Heart.png', 'Likes'),
                _buildBarItem(3, 'assets/images/Google_calendar.png', 'Schedule'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBarItem(int index, String iconData, String label) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            iconData,
            color: isSelected ? AppColors.mainBlackTextColor : AppColors.whiteColor,
          ),
          Text(
            label,
            style: appTextStyle12K(
              isSelected ? AppColors.mainBlackTextColor : AppColors.whiteColor,
            ),
          ),
        ],
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

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Profile Content', style: appTextStyle16(AppColors.mainBlackTextColor)),
    );
  }
}
