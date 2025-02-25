// import 'package:flutter/material.dart';

// class AppointmentScheduler extends StatefulWidget {
//   const AppointmentScheduler({super.key});

//   @override
//   State<AppointmentScheduler> createState() => _AppointmentSchedulerState();
// }

// class _AppointmentSchedulerState extends State<AppointmentScheduler> {
//   final Map<DayOfWeek, TimeRange> _freeTimes = {};

//   @override
//   void initState() {
//     super.initState();
//     // Initialize with default values for all days
//     for (var day in DayOfWeek.values) {
//       _freeTimes[day] = TimeRange(
//         start: const TimeOfDay(hour: 8, minute: 0),
//         end: const TimeOfDay(hour: 18, minute: 0),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Set Free Days and Times'),
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16.0),
//         children: DayOfWeek.values.map((day) {
//           return Card(
//             elevation: 2.0,
//             margin: const EdgeInsets.symmetric(vertical: 8.0),
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     day.name.toUpperCase(),
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text('Start Time: ${_freeTimes[day]!.start.format(context)}'),
//                       ElevatedButton(
//                         onPressed: () async {
//                           TimeOfDay? selectedTime = await showTimePicker(
//                             context: context,
//                             initialTime: _freeTimes[day]!.start,
//                           );
//                           if (selectedTime != null) {
//                             setState(() {
//                               _freeTimes[day] = TimeRange(
//                                 start: selectedTime,
//                                 end: _freeTimes[day]!.end,
//                               );
//                             });
//                           }
//                         },
//                         child: const Text('Select Start Time'),
//                       ),
//                     ],
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text('End Time: ${_freeTimes[day]!.end.format(context)}'),
//                       ElevatedButton(
//                         onPressed: () async {
//                           TimeOfDay? selectedTime = await showTimePicker(
//                             context: context,
//                             initialTime: _freeTimes[day]!.end,
//                           );
//                           if (selectedTime != null) {
//                             setState(() {
//                               _freeTimes[day] = TimeRange(
//                                 start: _freeTimes[day]!.start,
//                                 end: selectedTime,
//                               );
//                             });
//                           }
//                         },
//                         child: const Text('Select End Time'),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
// }

// // Enum for Days of the Week
// enum DayOfWeek { monday, tuesday, wednesday, thursday, friday, saturday, sunday }

// // Class to hold Time Range information
// class TimeRange {
//   final TimeOfDay start;
//   final TimeOfDay end;

//   const TimeRange({required this.start, required this.end});
// }

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:stylehub/constants/app/app_colors.dart';
import 'package:stylehub/constants/app/textstyle.dart';
import 'package:stylehub/constants/localization/locales.dart';
import 'package:stylehub/onboarding_page/onboarding_screen.dart';

class AppointmentScheduler extends StatefulWidget {
  const AppointmentScheduler({super.key});

  @override
  State<AppointmentScheduler> createState() => _AppointmentSchedulerState();
}

class _AppointmentSchedulerState extends State<AppointmentScheduler> {
  DateTime _currentMonth = DateTime.now();
  final bool _is24HourFormat = false;
  List<TimeSlot> _timeSlots = [];

  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _initializeTimeSlots();
  }

  void _initializeTimeSlots() {
    _timeSlots = List.generate(24, (hour) {
      return List.generate(7, (day) {
        return TimeSlot(
          day: day,
          hour: hour,
          isOpen: false,
        );
      });
    }).expand((i) => i).toList();
  }

  String _formatHour(int hour) {
    if (_is24HourFormat) {
      return '${hour.toString().padLeft(2, '0')}:00';
    }
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:00 $period';
  }

  void _toggleTimeSlot(TimeSlot slot) {
    setState(() {
      slot.isOpen = !slot.isOpen;
    });
    _sendToBackend();
  }

  void _sendToBackend() {
    final openedSlots = _timeSlots.where((slot) => slot.isOpen).toList();
    // Implement your backend API call here
    if (kDebugMode) {
      print('Opened slots to send to backend:');
      for (var slot in openedSlots) {
        // print('Day ${slot.day} @ ${slot.hour}:00 - ${slot.isOpen}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Day ${slot.day} @ ${_formatHour(slot.hour)} - ${slot.isOpen}'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 20.h, left: 12.w),
                child: Text(
                  'Schedule & Bookings',
                  style: appTextStyle24(AppColors.newThirdGrayColor),
                ),
              ),
              _buildMonthSelector(),
              Padding(
                padding: EdgeInsets.only(left: 60.w),
                child: _buildCalendarHeader(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildTimeTable(),
                      SizedBox(height: 24.h),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 16.w),
                            child: Text(
                              'Upcoming',
                              style: appTextStyle24(AppColors.newThirdGrayColor),
                            ),
                          ),
                          _buildUpcomingAppointments()
                        ],
                      ),
                      SizedBox(
                        height: 80.h,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Padding(
      padding: EdgeInsets.only(left: 8.w, right: 8.w, top: 33.h, bottom: 22.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 42.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.dg),
              border: Border.all(color: AppColors.appBGColor, width: 2.h),
            ),
            child: Center(
              child: Text(
                DateFormat('MMMM y').format(_currentMonth),
                style: appTextStyle16500(AppColors.newThirdGrayColor),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                height: 42.h,
                width: 44.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.dg),
                  border: Border.all(color: AppColors.appBGColor, width: 2.h),
                ),
                child: IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _changeMonth(-1),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                height: 42.h,
                width: 44.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.dg),
                  border: Border.all(color: AppColors.appBGColor, width: 2.h),
                ),
                child: IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _changeMonth(1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// The days of the week
  Widget _buildCalendarHeader() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.5,
      ),
      itemCount: _days.length,
      itemBuilder: (context, index) => Center(
        child: Text(
          _days[index],
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: AppColors.newThirdGrayColor),
        ),
      ),
    );
  }

  Widget _buildTimeTable() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 24,
      itemBuilder: (context, hourIndex) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              SizedBox(
                width: 60,
                child: Text(
                  _formatHour(hourIndex),
                  style: appTextStyle12K(AppColors.newThirdGrayColor),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: 7,
                  itemBuilder: (context, dayIndex) {
                    final slot = _timeSlots.firstWhere(
                      (s) => s.hour == hourIndex && s.day == dayIndex,
                    );
                    return GestureDetector(
                      onTap: () => _toggleTimeSlot(slot),
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: slot.isOpen ? Colors.green.shade100 : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: slot.isOpen ? Colors.green : Colors.grey,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            slot.isOpen ? 'Opened' : 'Open',
                            style: appTextStyle10(slot.isOpen ? Colors.green : Colors.black),

                            // TextStyle(
                            //   color: slot.isOpen ? Colors.green : Colors.black,
                            //   fontWeight: FontWeight.w500,
                            // ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _changeMonth(int delta) {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + delta);
    });
  }

  /// Widget design for upcoming appointments
  Widget _buildUpcomingAppointments() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(left: 18.w, right: 18.w, top: 23.h),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 19.h),
      decoration: BoxDecoration(color: AppColors.appBGColor, borderRadius: BorderRadius.circular(15.dg)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Icon(
              Icons.notifications_on_sharp,
            ),
          ),
          Text(
            'Specialist name',
            style: appTextStyle16400(AppColors.mainBlackTextColor),
          ),
          Text(
            'Date',
            style: appTextStyle16400(AppColors.mainBlackTextColor),
          ),
          Text(
            'Time',
            style: appTextStyle16400(AppColors.mainBlackTextColor),
          ),
          Text(
            'Agreed address of meeting',
            style: appTextStyle16400(AppColors.mainBlackTextColor),
          ),
          SizedBox(
            height: 10.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () => showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.dg),
                          ),
                          contentPadding: EdgeInsets.zero,
                          title: Column(
                            children: [
                              SizedBox(
                                width: 211.w,
                                child: Text(
                                  LocaleData.wantToCancelAppointment,
                                  style: appTextStyle16400(AppColors.mainBlackTextColor),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Date',
                                    style: appTextStyle16400(AppColors.mainBlackTextColor),
                                  ),
                                  SizedBox(
                                    width: 4.w,
                                  ),
                                  Text(
                                    'by',
                                    style: appTextStyle16400(AppColors.mainBlackTextColor),
                                  ),
                                  SizedBox(
                                    width: 4.w,
                                  ),
                                  Text(
                                    'Time',
                                    style: appTextStyle16400(AppColors.mainBlackTextColor),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          actions: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                    height: 25.h,
                                    width: 104.w,
                                    child: ReusableButton(
                                        color: AppColors.appBGColor,
                                        text: Text(
                                          LocaleData.no.getString(context),
                                          style: appTextStyle16400(AppColors.mainBlackTextColor),
                                        ),
                                        onPressed: () {})),
                                SizedBox(
                                    height: 25.h,
                                    width: 104.w,
                                    child: ReusableButton(
                                        color: AppColors.appBGColor,
                                        text: Text(
                                          LocaleData.yes.getString(context),
                                          style: appTextStyle16400(AppColors.mainBlackTextColor),
                                        ),
                                        onPressed: () {})),
                              ],
                            ),
                          ],
                        )),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.whiteColor,
                  minimumSize: Size(3.w, 25.h),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: AppColors.newGrayColor, width: 2.w),
                    borderRadius: BorderRadius.circular(5.dg),
                  ),
                ),
                child: Center(
                  child: Text(
                    LocaleData.cancel.getString(context),
                    style: appTextStyle12K(AppColors.mainBlackTextColor),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class TimeSlot {
  int day;
  int hour;
  bool isOpen;

  TimeSlot({
    required this.day,
    required this.hour,
    required this.isOpen,
  });
}
