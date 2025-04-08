// main.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:stylehub/constants/app/app_colors.dart';
import 'package:stylehub/constants/app/textstyle.dart';
import 'package:stylehub/onboarding_page/onboarding_screen.dart';
import 'package:stylehub/screens/specialist_pages/provider/specialist_provider.dart';
import 'package:stylehub/screens/specialist_pages/specialist_schedule_appointment_screen.dart';

class MakeAppointmentScreen extends StatefulWidget {
  final String specialistId;

  const MakeAppointmentScreen({super.key, required this.specialistId});

  @override
  State<MakeAppointmentScreen> createState() => _MakeAppointmentScreenState();
}

class _MakeAppointmentScreenState extends State<MakeAppointmentScreen> {
  DateTime _selectedDate = DateTime.now();
  // TimeSlot? _selectedSlot;
  final List<TimeSlot> _selectedSlots = [];
  final _firestore = FirebaseFirestore.instance;
  bool isLoading = false;

  // final _auth = FirebaseAuth.instance;

  /// Calculates the first Monday of the week for the given date.
  ///
  /// Given a date, the method subtracts days until the weekday of the date is
  /// Monday (DateTime.monday). The resulting date is the first Monday of the
  /// week.
  DateTime _getFirstMonday(DateTime date) {
    date = DateTime(date.year, date.month, date.day);
    while (date.weekday != DateTime.monday) {
      date = date.subtract(const Duration(days: 1));
    }
    return date;
  }

  /// Fetches the availability of the selected specialist for the selected week.
  ///
  /// The method first calculates the start of the current week by finding the
  /// first Monday of the week. It then fetches the Firestore document for the
  /// selected specialist's availability for the current week. If the document
  /// does not exist, an empty list is returned.
  ///
  /// The method then filters the fetched time slots for the selected date and
  /// returns a list of time slots that are open on the selected date.
  Future<List<TimeSlot>> _getAvailability() async {
    final weekStart = _getFirstMonday(_selectedDate);
    final doc = await _firestore.collection('availability').doc(widget.specialistId).collection('weeks').doc(weekStart.toIso8601String()).get();

    if (!doc.exists) return [];

    final slots = (doc.data()!['slots'] as List).map((slot) => TimeSlot.fromMap(slot)).toList();

    // Filter slots for selected date
    final selectedWeekday = _selectedDate.weekday - 1; // Monday = 0
    return slots.where((slot) => slot.day == selectedWeekday && slot.isOpen).toList();
  }

  /// Books selected time slots for an appointment with the given client's first and last name.
  ///
  /// The method first checks if any time slots have been selected. If no slots are selected,
  /// a message is shown to the user. It then retrieves the current authenticated user and
  /// checks if the user is available. If the user is not authenticated, the function exits.
  ///
  /// A Firebase Firestore batch operation is initiated to ensure atomic updates. The start
  /// of the current week is calculated, and the existing availability for the selected
  /// specialist is fetched from Firestore. The selected time slots are then iterated over,
  /// creating a new appointment document for each slot and updating the slot's availability
  /// to closed in the Firestore document.
  ///
  /// After updating the Firestore documents, the batch operation is committed, and a success
  /// message is displayed indicating the number of slots booked. If any error occurs during
  /// the operation, an error message is displayed to the user.

  Future<void> _bookAppointment(String firstName, String lastName) async {
    setState(() {
      isLoading = true;
    });

    if (_selectedSlots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least one time slot')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final batch = FirebaseFirestore.instance.batch();
      final weekStart = _getFirstMonday(_selectedDate);
      final weekKey = weekStart.toIso8601String();
      final availabilityRef = FirebaseFirestore.instance.collection('availability').doc(widget.specialistId).collection('weeks').doc(weekKey);

      // Get current availability
      final doc = await availabilityRef.get();
      List<TimeSlot> slots = [];
      if (doc.exists) {
        slots = (doc.data()!['slots'] as List).map((s) => TimeSlot.fromMap(s)).toList();
      }

      // Create appointments and update availability
      for (final slot in _selectedSlots) {
        // Create appointment
        final appointmentRef = FirebaseFirestore.instance.collection('appointments').doc();

        batch.set(appointmentRef, {
          'address': 'The client address',
          'appointmentId': appointmentRef.id,
          'clientFirstName': firstName,
          'clientLastName': lastName,
          'specialistId': widget.specialistId,
          'clientId': user.uid,
          'date': Timestamp.fromDate(DateTime(
            _selectedDate.year,
            _selectedDate.month,
            _selectedDate.day,
            slot.hour,
            slot.minute,
          )),
          'status': 'booked',
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Update availability
        final index = slots.indexWhere((s) => s.day == slot.day && s.hour == slot.hour && s.minute == slot.minute);
        if (index != -1) {
          slots[index] = slots[index].copyWith(isOpen: false);
        }
      }

      // Update availability document
      batch.set(
          availabilityRef,
          {
            'weekStart': Timestamp.fromDate(weekStart),
            'slots': slots.map((s) => s.toMap()).toList(),
            'lastUpdated': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true));

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully booked ${_selectedSlots.length} slots')),
      );
      setState(() => _selectedSlots.clear());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking failed: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _formatTime(int hour, int minute) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

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

// Update the FutureBuilder in build method
            FutureBuilder<List<TimeSlot>>(
              future: _getAvailability(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator.adaptive();
                }

                final slots = snapshot.data ?? [];
                if (slots.isEmpty) {
                  return Center(child: Text('No available time slots'));
                }

                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: slots.map((slot) {
                    return TimeSlotButton(
                      time: _formatTime(slot.hour, slot.minute),
                      isSelected: _selectedSlots.any((s) => s.day == slot.day && s.hour == slot.hour && s.minute == slot.minute),
                      onPressed: () => setState(() {
                        final existingIndex = _selectedSlots.indexWhere((s) => s.day == slot.day && s.hour == slot.hour && s.minute == slot.minute);

                        if (existingIndex != -1) {
                          _selectedSlots.removeAt(existingIndex);
                        } else {
                          _selectedSlots.add(slot);
                        }
                      }),
                    );
                  }).toList(),
                );
              },
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
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.dg),
                  border: Border.all(color: AppColors.appBGColor, width: 2.w),
                ),
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
            Consumer<SpecialistProvider>(builder: (context, provider, child) {
              return Center(
                child: SizedBox(
                  height: 44.3.h,
                  width: 202.w,
                  child: ReusableButton(
                    bgColor: AppColors.whiteColor,
                    color: AppColors.appBGColor,
                    text: isLoading
                        ? CircularProgressIndicator.adaptive()
                        : Text(
                            'Make Appointment',
                            style: appTextStyle15(AppColors.newThirdGrayColor),
                          ),
                    onPressed: () => _bookAppointment(provider.specialistModel!.firstName, provider.specialistModel!.lastName),
                  ),
                ),
              );
            }),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  // String _formatHour(int hour) {
  //   final period = hour >= 12 ? 'PM' : 'AM';
  //   final displayHour = hour % 12 == 0 ? 12 : hour % 12;
  //   return '$displayHour:00 $period';
  // }
}

class TimeSlotButton extends StatelessWidget {
  final String time;
  final bool isSelected;
  final VoidCallback onPressed;

  const TimeSlotButton({
    super.key,
    required this.time,
    this.isSelected = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected
            ? AppColors.appBGColor // Selected background color
            : AppColors.whiteColor, // Unselected background
        padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 8.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.dg),
        ),
        side: BorderSide(
          color: isSelected
              ? AppColors.mainBlackTextColor // Selected border color
              : AppColors.appBGColor, // Unselected border
          width: 2.w,
        ),
      ),
      child: Text(
        time,
        style: appTextStyle16500(isSelected
                ? AppColors.mainBlackTextColor // Selected text color
                : AppColors.newThirdGrayColor // Unselected text
            ),
      ),
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
