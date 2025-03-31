import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:stylehub/constants/app/app_colors.dart';
import 'package:stylehub/constants/app/textstyle.dart';
import 'package:stylehub/constants/localization/locales.dart';
import 'package:stylehub/onboarding_page/onboarding_screen.dart';
import 'package:stylehub/screens/specialist_pages/model/appointment_model.dart';
import 'package:stylehub/storage/appointment_repo.dart';

class AppointmentScreen extends StatelessWidget {
  const AppointmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.whiteColor,
        appBar: AppBar(
          backgroundColor: AppColors.whiteColor,
          centerTitle: false,
          title: Text(
            LocaleData.appointments.getString(context),
            style: appTextStyle24(AppColors.newThirdGrayColor),
          ),
        ),
        body: MyAppointmentsScreen(isSpecialist: true));
  }
}

class MyAppointmentsScreen extends StatefulWidget {
  final bool isSpecialist;
  const MyAppointmentsScreen({super.key, required this.isSpecialist});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
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

      await _repo.deleteAppointment(appointmentId);
      setState(() {
        // Remove the appointment from local list immediately
        _appointments.removeWhere((appt) => appt.appointmentId == appointmentId);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete appointment: $e')),
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
    return Scaffold(
      // appBar: AppBar(title: Text(widget.isSpecialist ? 'My Bookings' : 'My Appointments')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _appointments.isEmpty
              ? Center(child: Text('No appointments found'))
              : Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.86,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 70),
                        child: ListView.builder(
                          itemCount: _appointments.length,
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
                                                                'By ${formatDateTime(appointment.date)}',
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
                                                                  onPressed: () => _cancelAppointment(appointment.appointmentId),
                                                                )),
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
                ),
    );
  }
}

// Call this method and pass your DateTime object
String formatDateTime(DateTime dateTime) {
  // Example output: March 23, 2025 - 02:45 PM
  final DateFormat formatter = DateFormat('MMMM dd, yyyy - hh:mm a');
  return formatter.format(dateTime);
}
