import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:stylehub/constants/app/app_colors.dart';
import 'package:stylehub/constants/app/textstyle.dart';
import 'package:stylehub/constants/localization/locales.dart';
import 'package:stylehub/onboarding_page/onboarding_screen.dart';
import 'package:stylehub/screens/specialist_pages/model/appointment_model.dart';
import 'package:stylehub/screens/specialist_pages/provider/specialist_provider.dart';
import 'package:stylehub/storage/appointment_repo.dart';

class AppointmentScheduler extends StatefulWidget {
  const AppointmentScheduler({super.key});

  @override
  State<AppointmentScheduler> createState() => _AppointmentSchedulerState();
}

class _AppointmentSchedulerState extends State<AppointmentScheduler> {
  late DateTime _currentWeekStart;
  final bool _is24HourFormat = false;
  List<TimeSlot> _timeSlots = [];
  bool _isExpanded = false;
  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _currentWeekStart = _getFirstMonday(DateTime.now());
    _initializeTimeSlots();
    _loadSavedSlots();
    getUserInfo();
  }

  void getUserInfo() {
    Provider.of<SpecialistProvider>(context, listen: false).fetchSpecialistData();
  }

  void _initializeTimeSlots() {
    _timeSlots = List.generate(24, (hour) {
      return List.generate(7, (day) {
        return TimeSlot(day: day, hour: hour, isOpen: false);
      });
    }).expand((i) => i).toList();
  }

  DateTime _getFirstMonday(DateTime date) {
    date = DateTime(date.year, date.month, date.day);
    while (date.weekday != DateTime.monday) {
      date = date.subtract(const Duration(days: 1));
    }
    return date;
  }

  List<DateTime> _getWeekDates() {
    return List.generate(7, (index) => _currentWeekStart.add(Duration(days: index)));
  }

  void _changeWeek(int delta) {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(Duration(days: delta * 7));
    });
    // Load slots for new week
    _loadSavedSlots();
  }

  String _formatHour(int hour) {
    if (_is24HourFormat) return '${hour.toString().padLeft(2, '0')}:00';
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:00 $period';
  }

  // Check if a day is in the past relative to the current date
  bool _isDayInPast(int day) {
    final now = DateTime.now();
    final currentDayOfWeek = now.weekday; // Monday = 1, Sunday = 7
    final adjustedDay = day + 1; // Convert to weekday format (Monday = 1, Sunday = 7)

    // If the day is before the current day in the week, it's in the past
    return adjustedDay < currentDayOfWeek;
  }

  void _toggleTimeSlot(TimeSlot slot, String firstName, String lastName) {
    // Prevent toggling if the day is in the past
    if (_isDayInPast(slot.day)) {
      return;
    }
    setState(() => slot.isOpen = !slot.isOpen);
    _sendToBackend(firstName, lastName);
  }

  Future<void> _loadSavedSlots() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final weekKey = _currentWeekStart.toIso8601String();
    final doc = await FirebaseFirestore.instance.collection('availability').doc(user.uid).collection('weeks').doc(weekKey).get();

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      final savedSlots = (data['slots'] as List).map((slot) => TimeSlot.fromMap(slot)).toList();

      setState(() {
        _timeSlots = savedSlots;
      });
    }
  }

  Future<void> _sendToBackend(String firstName, String lastName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final weekKey = _currentWeekStart.toIso8601String();
    final slotsData = _timeSlots.map((slot) => slot.toMap()).toList();

    try {
      await FirebaseFirestore.instance.collection('availability').doc(user.uid).collection('weeks').doc(weekKey).set({
        'specialistId': user.uid,
        'specialistAddress': 'Asaba Nnebisi road, Port Harcourt',
        'specialistFirstName': firstName,
        'specialistLastName': lastName,
        'weekStart': _currentWeekStart,
        'slots': slotsData,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving slots: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final weekDates = _getWeekDates();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Schedule & Bookings',
          style: appTextStyle24(AppColors.newThirdGrayColor),
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
            child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // _buildHeader(),
              _buildWeekNavigator(),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.dg),
                  color: AppColors.appBGColor,
                ),
                padding: EdgeInsets.only(left: 0.w, right: 0.w, top: 12.h, bottom: 12.h),
                child: Container(
                  margin: EdgeInsets.only(left: 10.w, right: 0.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.dg),
                    color: AppColors.whiteColor,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 55.w,
                            ),
                            _buildCalendarHeader(weekDates),
                          ],
                        ),
                        SizedBox(
                          height: _isExpanded ? null : 240.h,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  child: _buildTimeTable(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                child: TextButton(
                  onPressed: () => setState(() => _isExpanded = !_isExpanded),
                  child: Row(
                    children: [
                      Text(
                        _isExpanded ? 'Show Less' : 'Expand',
                        style: appTextStyle24500(AppColors.newThirdGrayColor),
                      ),
                      SizedBox(width: 8.w),
                      SizedBox(
                        height: 18.h,
                        width: 18.w,
                        child: Image.asset(
                          'assets/images/Decompress.png',
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: 14.h),
              Padding(
                padding: EdgeInsets.only(left: 16.w),
                child: Text(
                  'Upcoming',
                  style: appTextStyle24(AppColors.newThirdGrayColor),
                ),
              ),
              // buildUpcomingAppointments(context),

              SizedBox(height: 400.h, child: AppointmentListScreen(isSpecialist: true)),
              SizedBox(
                height: 80.h,
              )
            ],
          ),
        )),
      ),
    );
  }

  // Widget _buildHeader() {
  //   return Padding(
  //     padding: EdgeInsets.only(top: 20.h, left: 12.w),
  //     child: Text(
  //       'Schedule & Bookings',
  //       style: appTextStyle24(AppColors.newThirdGrayColor),
  //     ),
  //   );
  // }

  Widget _buildWeekNavigator() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
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
                DateFormat('MMM y').format(_currentWeekStart),
                style: appTextStyle16500(AppColors.newThirdGrayColor),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                width: 44.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.dg),
                  border: Border.all(color: AppColors.appBGColor, width: 2.h),
                ),
                child: IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _changeWeek(-1),
                ),
              ),
              SizedBox(
                width: 4.w,
              ),
              Container(
                width: 44.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.dg),
                  border: Border.all(color: AppColors.appBGColor, width: 2.h),
                ),
                child: IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _changeWeek(1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader(List<DateTime> weekDates) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(7, (index) {
        final date = weekDates[index];
        final isCurrentMonth = date.month == _currentWeekStart.month;

        return Padding(
          padding: EdgeInsets.only(left: 4.w),
          child: Container(
            width: 79.w,
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
            child: Column(
              children: [
                Text(
                  _days[index],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isCurrentMonth ? Colors.black : Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  date.day.toString(),
                  style: TextStyle(
                    color: isCurrentMonth ? Colors.black : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTimeTable() {
    final user = Provider.of<SpecialistProvider>(context).specialistModel;
    return SizedBox(
      width: 80.w * 7.5,
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: 24,
        itemBuilder: (context, hourIndex) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 4.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 60.w,
                  child: Text(
                    _formatHour(hourIndex),
                    style: TextStyle(fontSize: 12.sp),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      childAspectRatio: 1.5,
                    ),
                    itemCount: 7,
                    itemBuilder: (context, dayIndex) {
                      final slot = _timeSlots.firstWhere(
                        (s) => s.hour == hourIndex && s.day == dayIndex,
                      );
                      final isPastDay = _isDayInPast(dayIndex);

                      return Consumer<SpecialistProvider>(builder: (context, provider, child) {
                        return GestureDetector(
                          onTap: isPastDay
                              ? null
                              : () => _toggleTimeSlot(
                                    slot,
                                    user!.firstName,
                                    user.lastName,
                                  ),
                          child: Container(
                            margin: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              color: isPastDay
                                  ? Colors.grey.shade400
                                  : slot.isOpen
                                      ? Colors.green.shade100
                                      : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(4.w),
                              border: Border.all(
                                color: isPastDay
                                    ? Colors.grey
                                    : slot.isOpen
                                        ? Colors.green
                                        : Colors.grey,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                isPastDay ? 'Unavailable' : (slot.isOpen ? 'Opened' : 'Open'),
                                style: TextStyle(
                                  color: isPastDay
                                      ? Colors.grey
                                      : slot.isOpen
                                          ? Colors.green
                                          : Colors.black,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ),
                          ),
                        );
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class TimeSlot {
  final int day;
  final int hour;
  bool isOpen;

  TimeSlot({
    required this.day,
    required this.hour,
    required this.isOpen,
  });

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'hour': hour,
      'isOpen': isOpen,
    };
  }

  factory TimeSlot.fromMap(Map<String, dynamic> map) {
    return TimeSlot(
      day: map['day'],
      hour: map['hour'],
      isOpen: map['isOpen'],
    );
  }

  TimeSlot copyWith({bool? isOpen}) {
    return TimeSlot(
      day: day,
      hour: hour,
      isOpen: isOpen ?? this.isOpen,
    );
  }
}

/// Widget design for upcoming appointments
Widget buildUpcomingAppointments(context) {
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
                        titlePadding: EdgeInsets.zero,
                        actionsPadding: EdgeInsets.only(top: 10.h, bottom: 20.h),
                        title: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                    onPressed: () => Navigator.pop(context),
                                    icon: Icon(
                                      Icons.close,
                                      color: AppColors.appBGColor,
                                    )),
                              ],
                            ),
                            SizedBox(
                              height: 6.h,
                            ),
                            SizedBox(
                              width: 211.w,
                              child: Text(
                                'Before canceling your booking you have to inform the client first , if you have done this , you can proceed to cancel , if not please inform client first',
                                style: appTextStyle16400(AppColors.mainBlackTextColor),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                  height: 32.h,
                                  width: 120.w,
                                  child: ReusableButton(
                                      color: AppColors.appBGColor,
                                      text: Text(
                                        LocaleData.cancel.getString(context),
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

class AppointmentListScreen extends StatefulWidget {
  final bool isSpecialist;
  const AppointmentListScreen({super.key, required this.isSpecialist});

  @override
  State<AppointmentListScreen> createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  final AppointmentRepository _repo = AppointmentRepository();
  List<AppointmentModel> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  /// Loads appointments for the current user.
  ///
  /// Uses the [AppointmentRepository] to fetch the appointments for the current
  /// user, and updates the [_appointments] list and [_isLoading] flag accordingly.
  ///
  /// This method is called in [initState] to load the appointments when the
  /// widget is first created.
  ///
  /// If the user is a specialist, the appointments are loaded for the specialist's
  /// bookings. Otherwise, the appointments are loaded for the user's bookings.
  Future<void> _loadAppointments() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final appointments = await _repo.fetchAppointments(
      userId: userId,
      isSpecialist: widget.isSpecialist,
    );
    setState(() {
      _appointments = appointments;
      _isLoading = false;
    });
  }

  Future<void> _cancelAppointment(String appointmentId) async {
    try {
      setState(() => _isLoading = true);

      await _repo.cancelAppointment(appointmentId);
      setState(() {
        // Remove the appointment from local list immediately
        _appointments.removeWhere((apt) => apt.appointmentId == appointmentId);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to cancel appointment: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : _appointments.isEmpty
            ? Center(child: Text('No appointments found'))
            : Column(
                children: [
                  Expanded(
                    // height: MediaQuery.of(context).size.height * 0.86,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 00),
                      child: ListView.builder(
                        itemCount: _appointments.length,
                        shrinkWrap: true,
                        // physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final appointment = _appointments[index];
                          return Column(
                            children: [
                              Container(
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
                                      widget.isSpecialist ? '${appointment.clientFirstName} ${appointment.clientLastName}' : 'Specialist: ${appointment.specialistId}',
                                      style: appTextStyle16400(AppColors.mainBlackTextColor),
                                    ),
                                    Text(
                                      formatDateTime(appointment.date),
                                      style: appTextStyle16400(AppColors.mainBlackTextColor),
                                    ),
                                    Text(
                                      appointment.address,
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
                                                    titlePadding: EdgeInsets.zero,
                                                    actionsPadding: EdgeInsets.only(top: 10.h, bottom: 20.h),
                                                    title: Column(
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.end,
                                                          children: [
                                                            IconButton(
                                                                onPressed: () => Navigator.pop(context),
                                                                icon: Icon(
                                                                  Icons.close,
                                                                  color: AppColors.appBGColor,
                                                                )),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: 6.h,
                                                        ),
                                                        SizedBox(
                                                          width: 211.w,
                                                          child: Text(
                                                            'Before canceling your booking you have to inform the client first , if you have done this , you can proceed to cancel , if not please inform client first',
                                                            style: appTextStyle16400(AppColors.mainBlackTextColor),
                                                            textAlign: TextAlign.center,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    actions: [
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          SizedBox(
                                                            height: 32.h,
                                                            width: 120.w,
                                                            child: ReusableButton(
                                                              color: AppColors.appBGColor,
                                                              text: Text(
                                                                LocaleData.cancel.getString(context),
                                                                style: appTextStyle16400(AppColors.mainBlackTextColor),
                                                              ),
                                                              onPressed: () {
                                                                Navigator.pop(context); // Close the dialog
                                                                _cancelAppointment(appointment.appointmentId);
                                                              },
                                                            ),
                                                          ),
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
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
  }

  String formatDateTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.day}/${date.month}/${date.year} at $hour:$minute';
  }
}
