// main.dart
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stylehub/constants/app/app_colors.dart';
import 'package:stylehub/constants/app/textstyle.dart';
import 'package:stylehub/onboarding_page/onboarding_screen.dart';

class MakeAppointmentScreen extends StatefulWidget {
  const MakeAppointmentScreen({super.key});

  @override
  State<MakeAppointmentScreen> createState() => _MakeAppointmentScreenState();
}

class _MakeAppointmentScreenState extends State<MakeAppointmentScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.dg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Make Appointment',
              style: appTextStyle24500(AppColors.mainBlackTextColor),
            ),
            SizedBox(
              height: 32.h,
            ),
            // Dynamic Month and Year Text
            // Container(
            //   padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            //   decoration: BoxDecoration(borderRadius: BorderRadius.circular(15.dg), border: Border.all(color: AppColors.appBGColor, width: 2.w)),
            //   child: Text(
            //     '${_getMonthName(_selectedDate.month)} ${_selectedDate.year}',
            //     style: appTextStyle16500(AppColors.newThirdGrayColor),
            //   ),
            // ),
            // SizedBox(height: 16),
            EasyDateTimeLine(
              initialDate: _selectedDate,
              onDateChange: (selectedDate) {
                setState(() {
                  _selectedDate = selectedDate;
                });
              },
              headerProps: EasyHeaderProps(
                monthPickerType: MonthPickerType.switcher,
                dateFormatter: DateFormatter.fullDateMonthAsStrDY(),
                selectedDateStyle: appTextStyle16500(AppColors.newThirdGrayColor),
              ),
              dayProps: EasyDayProps(
                dayStructure: DayStructure.dayStrDayNum,
                inactiveDayStyle: DayStyle(
                  // monthStrStyle: appTextStyle20(AppColors.newThirdGrayColor),
                  dayNumStyle: appTextStyle20(AppColors.newThirdGrayColor),
                  dayStrStyle: appTextStyle16400(AppColors.newThirdGrayColor),
                  decoration: BoxDecoration(
                    // color: Colors.grey.withValues(alpha: 0.5),
                    border: Border.all(color: AppColors.appBGColor, width: 2.w),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                activeDayStyle: DayStyle(
                  dayStrStyle: appTextStyle16400(AppColors.newThirdGrayColor),
                  monthStrStyle: appTextStyle20(AppColors.newThirdGrayColor),
                  dayNumStyle: appTextStyle20(AppColors.newThirdGrayColor),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.5),
                    border: Border.all(color: AppColors.appBGColor, width: 2.w),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Available Time Slots',
              style: appTextStyle24500(AppColors.mainBlackTextColor),
            ),
            SizedBox(height: 20.h),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: List.generate(5, (index) {
                return TimeSlotButton(time: '7:30 AM');
              }),
            ),
            SizedBox(height: 24),
            Text(
              'Address of Meeting',
              style: appTextStyle24500(AppColors.mainBlackTextColor),
            ),
            SizedBox(height: 8),
            AddressCard(
              crossAxisAlignment: CrossAxisAlignment.start,
              title: 'Your Address',
              address: '123 Client Street, City, Country',
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AddressCard(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  title: 'Client Address',
                  address: '456 Specialist Street, City, Country',
                ),
              ],
            ),
            SizedBox(
              height: 20.h,
            ),
            InkWell(
              onTap: () {},
              child: Container(
                // padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                width: 44.w,
                height: 42.h,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.dg), border: Border.all(color: AppColors.appBGColor, width: 2.w)),
                child: Center(
                    child: Icon(
                  Icons.add,
                  color: AppColors.newThirdGrayColor,
                  size: 26.h,
                )),
              ),
            ),

            // ),
            SizedBox(height: 54.h),
            Center(
              child: SizedBox(
                height: 44.3.h,
                width: 202.w,
                child: ReusableButton(
                    bgColor: AppColors.whiteColor,
                    color: AppColors.appBGColor,
                    text: Text(
                      'Make Appointment',
                      style: appTextStyle15(AppColors.newThirdGrayColor),
                    ),
                    onPressed: () {}),
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  // Helper function to get the month name from the month number
  // String _getMonthName(int month) {
  //   switch (month) {
  //     case 1:
  //       return 'January';
  //     case 2:
  //       return 'February';
  //     case 3:
  //       return 'March';
  //     case 4:
  //       return 'April';
  //     case 5:
  //       return 'May';
  //     case 6:
  //       return 'June';
  //     case 7:
  //       return 'July';
  //     case 8:
  //       return 'August';
  //     case 9:
  //       return 'September';
  //     case 10:
  //       return 'October';
  //     case 11:
  //       return 'November';
  //     case 12:
  //       return 'December';
  //     default:
  //       return '';
  //   }
  // }
}

class TimeSlotButton extends StatelessWidget {
  final String time;

  const TimeSlotButton({super.key, required this.time});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        // Handle time slot selection
      },
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 8.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.dg)),
        side: BorderSide(color: AppColors.appBGColor, width: 2.w),
      ),
      child: Text(time, style: appTextStyle16500(AppColors.newThirdGrayColor)),
    );
  }
}

class AddressCard extends StatelessWidget {
  final String title;
  final String address;
  final CrossAxisAlignment crossAxisAlignment;

  const AddressCard({
    super.key,
    required this.title,
    required this.address,
    required this.crossAxisAlignment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15.dg), border: Border.all(color: AppColors.appBGColor, width: 2.w)),
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4.h),
          Text(address, style: appTextStyle16500(AppColors.newThirdGrayColor)),
        ],
      ),
    );
  }
}
