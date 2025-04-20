import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:stylehub/constants/app/app_colors.dart';
import 'package:stylehub/constants/app/textstyle.dart';
import 'package:stylehub/constants/localization/locales.dart';
import 'package:stylehub/services/fcm_services/firebase_msg.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return const Center(child: Text('Please sign in to view appointments'));
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          LocaleData.appointments.getString(context),
          style: appTextStyle24(AppColors.newThirdGrayColor),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('appointments').where('clientId', isEqualTo: user.uid).orderBy('date', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No appointments booked yet',
                      style: appTextStyle16(AppColors.newThirdGrayColor),
                    ),
                  );
                }

                final appointments = snapshot.data!.docs;

                return ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    final appointment = appointments[index].data() as Map<String, dynamic>;
                    final date = (appointment['date'] as Timestamp).toDate();
                    final status = appointment['status'] as String? ?? 'booked';

                    return AppointmentCard(
                      specialistId: appointment['specialistId'] as String,
                      date: date,
                      status: status,
                      onCancel: () => _cancelAppointment(context, appointments[index].id),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            height: 50.h,
            color: Colors.transparent,
          )
        ],
      ),
    );
  }

  Future<void> _cancelAppointment(context, String appointmentId) async {
    FirebaseNotificationService firebasePushNotificationService = FirebaseNotificationService();
    try {
      // First get the appointment details
      final appointmentDoc = await _firestore.collection('appointments').doc(appointmentId).get();
      final appointment = appointmentDoc.data() as Map<String, dynamic>;
      final specialistId = appointment['specialistId'] as String;
      final date = (appointment['date'] as Timestamp).toDate();

      // Get specialist's FCM token
      final specialistDoc = await _firestore.collection('users').doc(specialistId).get();
      final specialistToken = specialistDoc['fcmToken'] as String?;
      final specialistName = '${specialistDoc['firstName']} ${specialistDoc['lastName']}';

      // Update appointment status
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });

      // Send notification to specialist
      if (specialistToken != null) {
        final formattedDate = DateFormat('EEE, MMM d, y').format(date);
        final formattedTime = DateFormat('h:mm a').format(date);

        firebasePushNotificationService.cancelPushNotification(
            'Appointment Cancelled', 'Your appointment on $formattedDate at $formattedTime with $specialistName has been cancelled', specialistToken);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment cancelled successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to cancel appointment: $e')),
      );
    }
  }

  // Future<void> _cancelAppointment(context, String appointmentId) async {
  //   try {
  //     await _firestore.collection('appointments').doc(appointmentId).update({
  //       'status': 'cancelled',
  //       'cancelledAt': FieldValue.serverTimestamp(),
  //     });

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Appointment cancelled successfully')),
  //     );
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to cancel appointment: $e')),
  //     );
  //   }
  // }
}

class AppointmentCard extends StatefulWidget {
  final String specialistId;
  final DateTime date;
  final String status;
  final VoidCallback onCancel;

  const AppointmentCard({
    super.key,
    required this.specialistId,
    required this.date,
    required this.status,
    required this.onCancel,
  });

  @override
  State<AppointmentCard> createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<AppointmentCard> {
  Map<String, dynamic>? _specialistData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSpecialistData();
  }

  Future<void> _loadSpecialistData() async {
    setState(() => _isLoading = true);
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(widget.specialistId).get();

      if (doc.exists) {
        setState(() {
          _specialistData = doc.data();
        });
      }
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.appBGColor,
      margin: EdgeInsets.only(bottom: 16.h),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColors.appBGColor, width: 1.w),
        borderRadius: BorderRadius.circular(12.dg),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLoading) const Center(child: CircularProgressIndicator()) else if (_specialistData != null) _buildSpecialistInfo(),
            SizedBox(height: 12.h),
            _buildAppointmentInfo(),
            SizedBox(height: 16.h),
            if (widget.status == 'booked') _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialistInfo() {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_specialistData?['firstName'] ?? ''} ${_specialistData?['lastName'] ?? ''}',
              style: appTextStyle16500(AppColors.mainBlackTextColor),
            ),
            Text(
              _specialistData?['profession']?.toString() ?? 'Specialist',
              style: appTextStyle14(AppColors.newThirdGrayColor),
            ),
          ],
        ),
        Spacer(),
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: _getStatusColor(),
                borderRadius: BorderRadius.circular(4.dg),
              ),
              child: Text(
                widget.status.toUpperCase(),
                style: appTextStyle12K(AppColors.whiteColor),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAppointmentInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Details',
          style: appTextStyle16500(AppColors.mainBlackTextColor),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Icon(Icons.calendar_today, size: 16.dg, color: AppColors.newThirdGrayColor),
            SizedBox(width: 8.w),
            Text(
              DateFormat('EEE, MMM d, y').format(widget.date),
              style: appTextStyle14(AppColors.newThirdGrayColor),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Row(
          children: [
            Icon(Icons.access_time, size: 16.dg, color: AppColors.newThirdGrayColor),
            SizedBox(width: 8.w),
            Text(
              DateFormat('h:mm a').format(widget.date),
              style: appTextStyle14(AppColors.newThirdGrayColor),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        // Row(
        //   children: [
        //     Container(
        //       padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        //       decoration: BoxDecoration(
        //         color: _getStatusColor(),
        //         borderRadius: BorderRadius.circular(4.dg),
        //       ),
        //       child: Text(
        //         widget.status.toUpperCase(),
        //         style: appTextStyle12K(AppColors.whiteColor),
        //       ),
        //     ),
        //   ],
        // ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        SizedBox(height: 16.h),
        Spacer(),
        SizedBox(height: 16.h),
        Spacer(),
        Expanded(
            child: GestureDetector(
          onTap: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    backgroundColor: AppColors.whiteColor,
                    contentPadding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.dg)),
                    content: Container(
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
                      height: 160.h,
                      child: Column(
                        children: [
                          Text(
                            'Are you sure you want to cancel this appointment on, ${DateFormat('EEE, MMM d, y').format(widget.date)} by ${DateFormat('h:mm a').format(widget.date)}',
                            style: appTextStyle14(AppColors.mainBlackTextColor),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16.h),
                          Row(
                            children: [
                              InkWell(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 40.w),
                                  decoration: BoxDecoration(color: AppColors.appBGColor, borderRadius: BorderRadius.circular(12.dg)),
                                  child: Text('No'),
                                ),
                              ),
                              Spacer(),
                              InkWell(
                                onTap: widget.onCancel,
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 40.w),
                                  decoration: BoxDecoration(color: AppColors.appBGColor, borderRadius: BorderRadius.circular(12.dg)),
                                  child: Text('Yes'),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  )),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 4.h),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.dg), color: AppColors.whiteColor),
            child: Center(child: Text(LocaleData.cancel.getString(context), style: appTextStyle12K(AppColors.mainBlackTextColor))),
          ),
        )),
        // SizedBox(width: 16.w),
        // Expanded(
        //   child: ElevatedButton(
        //     onPressed: () {
        //       // Handle reschedule or other actions
        //     },
        //     style: ElevatedButton.styleFrom(
        //       backgroundColor: AppColors.appBGColor,
        //       padding: EdgeInsets.symmetric(vertical: 12.h),
        //     ),
        //     child: Text(
        //       'Reschedule',
        //       style: appTextStyle14(AppColors.whiteColor),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (widget.status) {
      case 'booked':
        return AppColors.greenColor;
      case 'cancelled':
        return AppColors.primaryRedColor;
      case 'completed':
        return AppColors.mainColor;
      default:
        return AppColors.grayColor;
    }
  }
}
