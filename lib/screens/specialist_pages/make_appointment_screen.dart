// // main.dart
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:easy_date_timeline/easy_date_timeline.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_localization/flutter_localization.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:provider/provider.dart';
// import 'package:stylehub/constants/app/app_colors.dart';
// import 'package:stylehub/constants/app/textstyle.dart';
// import 'package:stylehub/constants/localization/locales.dart';
// import 'package:stylehub/onboarding_page/onboarding_screen.dart';
// import 'package:stylehub/screens/specialist_pages/provider/specialist_provider.dart';
// import 'package:stylehub/screens/specialist_pages/specialist_schedule_appointment_screen.dart';
// import 'package:stylehub/screens/specialist_pages/success_screen.dart';

// class MakeAppointmentScreen extends StatefulWidget {
//   final String specialistId;

//   const MakeAppointmentScreen({super.key, required this.specialistId});

//   @override
//   State<MakeAppointmentScreen> createState() => _MakeAppointmentScreenState();
// }

// class _MakeAppointmentScreenState extends State<MakeAppointmentScreen> {
//   DateTime _selectedDate = DateTime.now();
//   // TimeSlot? _selectedSlot;
//   final List<TimeSlot> _selectedSlots = [];
//   final _firestore = FirebaseFirestore.instance;
//   bool isLoading = false;

//   // final _auth = FirebaseAuth.instance;

//   /// Calculates the first Monday of the week for the given date.
//   ///
//   /// Given a date, the method subtracts days until the weekday of the date is
//   /// Monday (DateTime.monday). The resulting date is the first Monday of the
//   /// week.
//   DateTime _getFirstMonday(DateTime date) {
//     date = DateTime(date.year, date.month, date.day);
//     while (date.weekday != DateTime.monday) {
//       date = date.subtract(const Duration(days: 1));
//     }
//     return date;
//   }

//   /// Fetches the availability of the selected specialist for the selected week.
//   ///
//   /// The method first calculates the start of the current week by finding the
//   /// first Monday of the week. It then fetches the Firestore document for the
//   /// selected specialist's availability for the current week. If the document
//   /// does not exist, an empty list is returned.
//   ///
//   /// The method then filters the fetched time slots for the selected date and
//   /// returns a list of time slots that are open on the selected date.
//   // Future<List<TimeSlot>> _getAvailability() async {
//   //   final weekStart = _getFirstMonday(_selectedDate);
//   //   final doc = await _firestore.collection('availability').doc(widget.specialistId).collection('weeks').doc(weekStart.toIso8601String()).get();

//   //   if (!doc.exists) return [];

//   //   final slots = (doc.data()!['slots'] as List).map((slot) => TimeSlot.fromMap(slot)).toList();

//   //   // Filter slots for selected date
//   //   final selectedWeekday = _selectedDate.weekday - 1; // Monday = 0
//   //   return slots.where((slot) => slot.day == selectedWeekday && slot.isOpen).toList();
//   // }
//   // Update your _getAvailability method to include duration checks:
//   Future<List<TimeSlot>> _getAvailability() async {
//     final weekStart = _getFirstMonday(_selectedDate);
//     final doc = await _firestore.collection('availability').doc(widget.specialistId).collection('weeks').doc(weekStart.toIso8601String()).get();

//     if (!doc.exists) return [];

//     final slots = (doc.data()!['slots'] as List).map((slot) => TimeSlot.fromMap(slot)).toList();
//     final selectedWeekday = _selectedDate.weekday - 1;

//     // Filter slots for selected date and apply duration rules
//     return slots.where((slot) {
//       if (slot.day != selectedWeekday || !slot.isOpen) return false;

//       // Check if this slot would overlap with any selected slots
//       for (final selectedSlot in _selectedSlots) {
//         if (_slotsOverlap(slot, selectedSlot)) {
//           return false;
//         }
//       }

//       return true;
//     }).toList();
//   }

//   bool _slotsOverlap(TimeSlot slot1, TimeSlot slot2) {
//     // Convert slots to DateTime for easier comparison
//     final start1 = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, slot1.hour, slot1.minute);
//     final end1 = start1.add(Duration(minutes: Provider.of<SpecialistProvider>(context, listen: false).totalDuration));

//     final start2 = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, slot2.hour, slot2.minute);
//     final end2 = start2.add(Duration(minutes: Provider.of<SpecialistProvider>(context, listen: false).totalDuration));

//     // Check for overlap with 15 minute buffer
//     return (start1.isBefore(end2.add(Duration(minutes: 15))) && (end1.add(Duration(minutes: 15)).isAfter(start2)));
//   }

//   /// Books selected time slots for an appointment with the given client's first and last name.
//   ///
//   /// The method first checks if any time slots have been selected. If no slots are selected,
//   /// a message is shown to the user. It then retrieves the current authenticated user and
//   /// checks if the user is available. If the user is not authenticated, the function exits.
//   ///
//   /// A Firebase Firestore batch operation is initiated to ensure atomic updates. The start
//   /// of the current week is calculated, and the existing availability for the selected
//   /// specialist is fetched from Firestore. The selected time slots are then iterated over,
//   /// creating a new appointment document for each slot and updating the slot's availability
//   /// to closed in the Firestore document.
//   ///
//   /// After updating the Firestore documents, the batch operation is committed, and a success
//   /// message is displayed indicating the number of slots booked. If any error occurs during
//   /// the operation, an error message is displayed to the user.

//   // Future<void> _bookAppointment(String firstName, String lastName) async {
//   //   setState(() {
//   //     isLoading = true;
//   //   });

//   //   if (_selectedSlots.isEmpty) {
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(content: Text('Please select at least one time slot')),
//   //     );
//   //     return;
//   //   }

//   //   final user = FirebaseAuth.instance.currentUser;
//   //   if (user == null) return;

//   //   try {
//   //     final batch = FirebaseFirestore.instance.batch();
//   //     final weekStart = _getFirstMonday(_selectedDate);
//   //     final weekKey = weekStart.toIso8601String();
//   //     final availabilityRef = FirebaseFirestore.instance.collection('availability').doc(widget.specialistId).collection('weeks').doc(weekKey);

//   //     // Get current availability
//   //     final doc = await availabilityRef.get();
//   //     List<TimeSlot> slots = [];
//   //     if (doc.exists) {
//   //       slots = (doc.data()!['slots'] as List).map((s) => TimeSlot.fromMap(s)).toList();
//   //     }

//   //     // Create appointments and update availability
//   //     for (final slot in _selectedSlots) {
//   //       // Create appointment
//   //       final appointmentRef = FirebaseFirestore.instance.collection('appointments').doc();

//   //       batch.set(appointmentRef, {
//   //         'address': 'The client address',
//   //         'appointmentId': appointmentRef.id,
//   //         'clientFirstName': firstName,
//   //         'clientLastName': lastName,
//   //         'specialistId': widget.specialistId,
//   //         'clientId': user.uid,
//   //         'date': Timestamp.fromDate(DateTime(
//   //           _selectedDate.year,
//   //           _selectedDate.month,
//   //           _selectedDate.day,
//   //           slot.hour,
//   //           slot.minute,
//   //         )),
//   //         'status': 'booked',
//   //         'createdAt': FieldValue.serverTimestamp(),
//   //       });

//   //       // Update availability
//   //       final index = slots.indexWhere((s) => s.day == slot.day && s.hour == slot.hour && s.minute == slot.minute);
//   //       if (index != -1) {
//   //         slots[index] = slots[index].copyWith(isOpen: false);
//   //       }
//   //     }

//   //     // Update availability document
//   //     batch.set(
//   //         availabilityRef,
//   //         {
//   //           'weekStart': Timestamp.fromDate(weekStart),
//   //           'slots': slots.map((s) => s.toMap()).toList(),
//   //           'lastUpdated': FieldValue.serverTimestamp(),
//   //         },
//   //         SetOptions(merge: true));

//   //     await batch.commit();

//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(content: Text('Successfully booked ${_selectedSlots.length} slots')),
//   //     );
//   //     setState(() => _selectedSlots.clear());
//   //     Navigator.push(context, MaterialPageRoute(builder: (context) => SuccessScreen()));
//   //   } catch (e) {
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(content: Text('Booking failed: $e')),
//   //     );
//   //   } finally {
//   //     setState(() {
//   //       isLoading = false;
//   //     });
//   //   }
//   // }

//   Future<void> _bookAppointment(String firstName, String lastName) async {
//     setState(() => isLoading = true);

//     final specialistProvider = Provider.of<SpecialistProvider>(context, listen: false);

//     if (_selectedSlots.isEmpty || specialistProvider.selectedServices.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please select at least one time slot and service')),
//       );
//       setState(() => isLoading = false);
//       return;
//     }

//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) return;

//     try {
//       final batch = FirebaseFirestore.instance.batch();
//       final weekStart = _getFirstMonday(_selectedDate);
//       final weekKey = weekStart.toIso8601String();
//       final availabilityRef = _firestore.collection('availability').doc(widget.specialistId).collection('weeks').doc(weekKey);

//       // Get current availability
//       final doc = await availabilityRef.get();
//       List<TimeSlot> slots = [];
//       if (doc.exists) {
//         slots = (doc.data()!['slots'] as List).map((s) => TimeSlot.fromMap(s)).toList();
//       }

//       // Create appointments and update availability
//       for (final slot in _selectedSlots) {
//         final appointmentRef = _firestore.collection('appointments').doc();

//         batch.set(appointmentRef, {
//           'address': 'The client address',
//           'appointmentId': appointmentRef.id,
//           'clientFirstName': firstName,
//           'clientLastName': lastName,
//           'specialistId': widget.specialistId,
//           'clientId': user.uid,
//           'date': Timestamp.fromDate(DateTime(
//             _selectedDate.year,
//             _selectedDate.month,
//             _selectedDate.day,
//             slot.hour,
//             slot.minute,
//           )),
//           'services': specialistProvider.selectedServices,
//           'totalDuration': specialistProvider.totalDuration,
//           'status': 'booked',
//           'createdAt': FieldValue.serverTimestamp(),
//         });

//         // Block time slots based on total duration (including 15 min buffer)
//         final startTime = DateTime(
//           _selectedDate.year,
//           _selectedDate.month,
//           _selectedDate.day,
//           slot.hour,
//           slot.minute,
//         );
//         final endTime = startTime.add(Duration(minutes: specialistProvider.totalDuration + 15));

//         // Update all slots that fall within this time range
//         for (var i = 0; i < slots.length; i++) {
//           final currentSlot = slots[i];
//           final currentTime = DateTime(
//             _selectedDate.year,
//             _selectedDate.month,
//             _selectedDate.day,
//             currentSlot.hour,
//             currentSlot.minute,
//           );

//           if (currentTime.isAfter(startTime.subtract(Duration(minutes: 1))) && currentTime.isBefore(endTime)) {
//             slots[i] = currentSlot.copyWith(isOpen: false);
//           }
//         }
//       }

//       // Update availability document
//       batch.set(
//         availabilityRef,
//         {
//           'weekStart': Timestamp.fromDate(weekStart),
//           'slots': slots.map((s) => s.toMap()).toList(),
//           'lastUpdated': FieldValue.serverTimestamp(),
//         },
//         SetOptions(merge: true),
//       );

//       await batch.commit();

//       // Clear selections after booking
//       specialistProvider.clearSelections();
//       setState(() => _selectedSlots.clear());

//       Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => SuccessScreen(),
//           ));
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Booking failed: $e')),
//       );
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   String _formatTime(int hour, int minute) {
//     final period = hour >= 12 ? 'PM' : 'AM';
//     final displayHour = hour % 12 == 0 ? 12 : hour % 12;
//     return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16.dg),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Make Appointment',
//               style: appTextStyle24500(AppColors.mainBlackTextColor),
//             ),
//             SizedBox(
//               height: 32.h,
//             ),

//             EasyDateTimeLine(
//               initialDate: _selectedDate,
//               onDateChange: (selectedDate) {
//                 setState(() {
//                   _selectedDate = selectedDate;
//                 });
//               },
//               headerProps: EasyHeaderProps(
//                 monthPickerType: MonthPickerType.switcher,
//                 dateFormatter: DateFormatter.fullDateMonthAsStrDY(),
//                 selectedDateStyle: appTextStyle16500(AppColors.newThirdGrayColor),
//               ),
//               dayProps: EasyDayProps(
//                 dayStructure: DayStructure.dayStrDayNum,
//                 inactiveDayStyle: DayStyle(
//                   // monthStrStyle: appTextStyle20(AppColors.newThirdGrayColor),
//                   dayNumStyle: appTextStyle20(AppColors.newThirdGrayColor),
//                   dayStrStyle: appTextStyle16400(AppColors.newThirdGrayColor),
//                   decoration: BoxDecoration(
//                     // color: Colors.grey.withValues(alpha: 0.5),
//                     border: Border.all(color: AppColors.appBGColor, width: 2.w),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 activeDayStyle: DayStyle(
//                   dayStrStyle: appTextStyle16400(AppColors.newThirdGrayColor),
//                   monthStrStyle: appTextStyle20(AppColors.newThirdGrayColor),
//                   dayNumStyle: appTextStyle20(AppColors.newThirdGrayColor),
//                   decoration: BoxDecoration(
//                     color: Colors.grey.withValues(alpha: 0.5),
//                     border: Border.all(color: AppColors.appBGColor, width: 2.w),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(height: 24),
//             Text(
//               'Available Time Slots',
//               style: appTextStyle24500(AppColors.mainBlackTextColor),
//             ),
//             SizedBox(height: 20.h),

// // Update the FutureBuilder in build method
//             FutureBuilder<List<TimeSlot>>(
//               future: _getAvailability(),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return CircularProgressIndicator.adaptive();
//                 }

//                 final slots = snapshot.data ?? [];
//                 if (slots.isEmpty) {
//                   return Center(child: Text('No available time slots'));
//                 }

//                 return Wrap(
//                   spacing: 8,
//                   runSpacing: 8,
//                   children: slots.map((slot) {
//                     return Tooltip(
//                       message: 'Select for ${Provider.of<SpecialistProvider>(context, listen: false).totalDuration} min service',
//                       child: TimeSlotButton(
//                         time: _formatTime(slot.hour, slot.minute),
//                         isSelected: _selectedSlots.any((s) => s.day == slot.day && s.hour == slot.hour && s.minute == slot.minute),
//                         onPressed: () {
//                           final provider = Provider.of<SpecialistProvider>(context, listen: false);
//                           if (provider.selectedServices.isEmpty) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(content: Text('Please select at least one service first')),
//                             );
//                             return;
//                           }

//                           setState(() {
//                             final existingIndex = _selectedSlots.indexWhere((s) => s.day == slot.day && s.hour == slot.hour && s.minute == slot.minute);
//                             if (existingIndex != -1) {
//                               _selectedSlots.removeAt(existingIndex);
//                             } else {
//                               _selectedSlots.add(slot);
//                             }
//                           });
//                         },
//                       ),
//                     );
//                   }).toList(),
//                   // children: slots.map((slot) {
//                   //   return TimeSlotButton(
//                   //     time: _formatTime(slot.hour, slot.minute),
//                   //     isSelected: _selectedSlots.any((s) => s.day == slot.day && s.hour == slot.hour && s.minute == slot.minute),
//                   //     onPressed: () => setState(() {
//                   //       final existingIndex = _selectedSlots.indexWhere((s) => s.day == slot.day && s.hour == slot.hour && s.minute == slot.minute);

//                   //       if (existingIndex != -1) {
//                   //         _selectedSlots.removeAt(existingIndex);
//                   //       } else {
//                   //         _selectedSlots.add(slot);
//                   //       }
//                   //     }),
//                   //   );
//                   // }).toList(),
//                 );
//               },
//             ),
//             SizedBox(height: 24),
//             Text(
//               LocaleData.services.getString(context),
//               style: appTextStyle24500(AppColors.mainBlackTextColor),
//             ),
//             // Display services
//             // In your MakeAppointmentScreen widget, update the services StreamBuilder:
//             StreamBuilder(
//               stream: FirebaseFirestore.instance.collection('users').doc(widget.specialistId).snapshots(),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return Center(child: CircularProgressIndicator());
//                 }

//                 final userData = snapshot.data!.data() as Map<String, dynamic>;
//                 final services = List<Map<String, dynamic>>.from(userData['services'] ?? []);

//                 if (services.isEmpty && !snapshot.hasData) {
//                   return Center(child: Text('Specialist Has not listed any services'));
//                 }

//                 return Column(
//                   children: services.map((service) {
//                     final isSelected = Provider.of<SpecialistProvider>(context, listen: false).isServiceSelected(service['service']);

//                     return InkWell(
//                       onTap: () {
//                         Provider.of<SpecialistProvider>(context, listen: false).toggleServiceSelection(service);
//                       },
//                       child: Container(
//                         margin: EdgeInsets.symmetric(vertical: 4.h),
//                         padding: EdgeInsets.all(12.w),
//                         decoration: BoxDecoration(
//                           color: isSelected ? AppColors.appBGColor.withOpacity(0.2) : Colors.transparent,
//                           border: Border.all(
//                             color: isSelected ? AppColors.appBGColor : Colors.grey.shade300,
//                             width: 1.5.w,
//                           ),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Row(
//                           children: [
//                             Icon(
//                               isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
//                               color: isSelected ? AppColors.appBGColor : Colors.grey,
//                             ),
//                             SizedBox(width: 12.w),
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   service['service'] ?? 'Service',
//                                   style: appTextStyle14(AppColors.mainBlackTextColor),
//                                 ),
//                                 Text(
//                                   '${service['price']} • ${service['duration']} mins',
//                                   style: appTextStyle12K(AppColors.newThirdGrayColor),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   }).toList(),
//                 );
//               },
//             ),
//             SizedBox(height: 24),
//             Text(
//               'Address of Meeting',
//               style: appTextStyle24500(AppColors.mainBlackTextColor),
//             ),
//             SizedBox(height: 8),
//             AddressCard(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               title: 'Your Address',
//               address: '123 Client Street, City, Country',
//             ),
//             SizedBox(height: 8),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 AddressCard(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   title: 'Client Address',
//                   address: '456 Specialist Street, City, Country',
//                 ),
//               ],
//             ),
//             SizedBox(
//               height: 20.h,
//             ),
//             InkWell(
//               onTap: () {},
//               child: Container(
//                 // padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
//                 width: 44.w,
//                 height: 42.h,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(10.dg),
//                   border: Border.all(color: AppColors.appBGColor, width: 2.w),
//                 ),
//                 child: Center(
//                     child: Icon(
//                   Icons.add,
//                   color: AppColors.newThirdGrayColor,
//                   size: 26.h,
//                 )),
//               ),
//             ),

//             // ),
//             SizedBox(height: 54.h),
//             Consumer<SpecialistProvider>(builder: (context, provider, child) {
//               return Center(
//                 child: SizedBox(
//                   height: 44.3.h,
//                   width: 202.w,
//                   child: ReusableButton(
//                     bgColor: AppColors.whiteColor,
//                     color: AppColors.appBGColor,
//                     text: isLoading
//                         ? CircularProgressIndicator.adaptive()
//                         : Text(
//                             'Make Appointment',
//                             style: appTextStyle15(AppColors.newThirdGrayColor),
//                           ),
//                     onPressed: () => _bookAppointment(provider.specialistModel!.firstName, provider.specialistModel!.lastName),
//                   ),
//                 ),
//               );
//             }),
//             SizedBox(height: 24.h),
//           ],
//         ),
//       ),
//     );
//   }

//   // String _formatHour(int hour) {
//   //   final period = hour >= 12 ? 'PM' : 'AM';
//   //   final displayHour = hour % 12 == 0 ? 12 : hour % 12;
//   //   return '$displayHour:00 $period';
//   // }
// }

// //

// class TimeSlotButton extends StatelessWidget {
//   final String time;
//   final bool isSelected;
//   final VoidCallback onPressed;

//   const TimeSlotButton({
//     super.key,
//     required this.time,
//     this.isSelected = false,
//     required this.onPressed,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return OutlinedButton(
//       onPressed: onPressed,
//       style: OutlinedButton.styleFrom(
//         backgroundColor: isSelected
//             ? AppColors.appBGColor // Selected background color
//             : AppColors.whiteColor, // Unselected background
//         padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 8.h),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(15.dg),
//         ),
//         side: BorderSide(
//           color: isSelected
//               ? AppColors.mainBlackTextColor // Selected border color
//               : AppColors.appBGColor, // Unselected border
//           width: 2.w,
//         ),
//       ),
//       child: Text(
//         time,
//         style: appTextStyle16500(isSelected
//                 ? AppColors.mainBlackTextColor // Selected text color
//                 : AppColors.newThirdGrayColor // Unselected text
//             ),
//       ),
//     );
//   }
// }

// class AddressCard extends StatelessWidget {
//   final String title;
//   final String address;
//   final CrossAxisAlignment crossAxisAlignment;

//   const AddressCard({
//     super.key,
//     required this.title,
//     required this.address,
//     required this.crossAxisAlignment,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//       decoration: BoxDecoration(borderRadius: BorderRadius.circular(15.dg), border: Border.all(color: AppColors.appBGColor, width: 2.w)),
//       child: Column(
//         crossAxisAlignment: crossAxisAlignment,
//         children: [
//           Text(
//             title,
//             style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
//           ),
//           SizedBox(height: 4.h),
//           Text(address, style: appTextStyle16500(AppColors.newThirdGrayColor)),
//         ],
//       ),
//     );
//   }
// }

// main.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:stylehub/constants/Helpers/app_helpers.dart';
import 'package:stylehub/constants/app/app_colors.dart';
import 'package:stylehub/constants/app/textstyle.dart';
import 'package:stylehub/constants/localization/locales.dart';
import 'package:stylehub/onboarding_page/onboarding_screen.dart';
import 'package:stylehub/screens/specialist_pages/provider/location_provider.dart';
import 'package:stylehub/screens/specialist_pages/provider/specialist_provider.dart';
import 'package:stylehub/screens/specialist_pages/success_screen.dart';
import 'package:stylehub/screens/specialist_pages/widgets/select_address_widget.dart';

// Define your TimeSlot model if not defined already:
class TimeSlot {
  final int day;
  final int hour;
  final int minute;
  final bool isOpen;

  TimeSlot({
    required this.day,
    required this.hour,
    required this.minute,
    required this.isOpen,
  });

  factory TimeSlot.fromMap(Map<String, dynamic> map) {
    return TimeSlot(
      day: map['day'],
      hour: map['hour'],
      minute: map['minute'],
      isOpen: map['isOpen'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'hour': hour,
      'minute': minute,
      'isOpen': isOpen,
    };
  }

  TimeSlot copyWith({bool? isOpen}) {
    return TimeSlot(
      day: day,
      hour: hour,
      minute: minute,
      isOpen: isOpen ?? this.isOpen,
    );
  }
}

class MakeAppointmentScreen extends StatefulWidget {
  final String specialistId;

  const MakeAppointmentScreen({super.key, required this.specialistId});

  @override
  State<MakeAppointmentScreen> createState() => _MakeAppointmentScreenState();
}

class _MakeAppointmentScreenState extends State<MakeAppointmentScreen> {
  DateTime _selectedDate = DateTime.now();
  final List<TimeSlot> _selectedSlots = [];
  final _firestore = FirebaseFirestore.instance;
  bool isLoading = false;

  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() {
    Provider.of<SpecialistProvider>(context, listen: false).fetchSpecialistData();
  }

  /// Returns the first Monday for the week in which [date] lies.
  DateTime _getFirstMonday(DateTime date) {
    date = DateTime(date.year, date.month, date.day);
    while (date.weekday != DateTime.monday) {
      date = date.subtract(const Duration(days: 1));
    }
    return date;
  }

  /// Revised availability fetch:
  /// Only filter out candidate slots if the candidate’s start time is AFTER
  /// a selected slot’s start time and falls within the block of appointment duration + 15 minute break.
  Future<List<TimeSlot>> _getAvailability() async {
    final weekStart = _getFirstMonday(_selectedDate);
    final doc = await _firestore.collection('availability').doc(widget.specialistId).collection('weeks').doc(weekStart.toIso8601String()).get();

    if (!doc.exists) return [];

    final slots = (doc.data()!['slots'] as List).map((s) => TimeSlot.fromMap(s)).toList();
    final selectedWeekday = _selectedDate.weekday - 1;

    // Provider is needed to get total service duration.
    final totalServiceDuration = Provider.of<SpecialistProvider>(context, listen: false).totalDuration;

    return slots.where((slot) {
      if (slot.day != selectedWeekday || !slot.isOpen) return false;

      // Loop through selected slots to see if this candidate slot should be blocked.
      for (final selectedSlot in _selectedSlots) {
        if (_shouldBlockCandidateSlot(slot, selectedSlot, totalServiceDuration)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  /// Determines if [candidate] should be blocked because it follows a selected slot
  /// by less than the combined duration of services plus a 15 minute break.
  bool _shouldBlockCandidateSlot(TimeSlot candidate, TimeSlot selected, int serviceDuration) {
    // Build DateTime objects for comparison
    final selectedStart = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      selected.hour,
      selected.minute,
    );
    final candidateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      candidate.hour,
      candidate.minute,
    );
    // Block only candidates that come AFTER the selected slot.
    if (candidateTime.isBefore(selectedStart)) return false;

    final appointmentEnd = selectedStart.add(Duration(minutes: serviceDuration));
    final breakEnd = appointmentEnd.add(const Duration(minutes: 15));
    // If candidate slot is before breakEnd, then block it.
    return candidateTime.isBefore(breakEnd);
  }

  /// Books the appointment. Each selected slot will become an appointment
  /// and in the availability document, only slots that start after the selected slot
  /// and fall within the (duration + 15 minutes) block will be marked as closed.
  Future<void> _bookAppointment(String firstName, String lastName) async {
    setState(() => isLoading = true);
    final specialistProvider = Provider.of<SpecialistProvider>(context, listen: false);
    final addressProvider = Provider.of<AddressProvider>(context, listen: false);

    if (_selectedSlots.isEmpty || specialistProvider.selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one time slot and service')),
      );
      setState(() => isLoading = false);
      return;
    }
    if (addressProvider.selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your address')),
      );
      setState(() => isLoading = false);
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final batch = FirebaseFirestore.instance.batch();
      final weekStart = _getFirstMonday(_selectedDate);
      final weekKey = weekStart.toIso8601String();
      final availabilityRef = _firestore.collection('availability').doc(widget.specialistId).collection('weeks').doc(weekKey);

      // Fetch current slots availability.
      final doc = await availabilityRef.get();
      List<TimeSlot> slots = [];
      if (doc.exists) {
        slots = (doc.data()!['slots'] as List).map((s) => TimeSlot.fromMap(s)).toList();
      }

      // Total service duration that applies to all selected slots.
      final totalServiceDuration = specialistProvider.totalDuration;

      // For each selected slot, create an appointment and update the availability.
      for (final slot in _selectedSlots) {
        final appointmentRef = _firestore.collection('appointments').doc();

        // Create appointment document.
        batch.set(appointmentRef, {
          'address': addressProvider.selectedAddress!.details,
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
          'services': specialistProvider.selectedServices,
          'totalDuration': totalServiceDuration,
          'status': 'booked',
          'createdAt': FieldValue.serverTimestamp(),
        });

        final startTime = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          slot.hour,
          slot.minute,
        );
        final appointmentEnd = startTime.add(Duration(minutes: totalServiceDuration));
        final breakEnd = appointmentEnd.add(const Duration(minutes: 15));

        // Only mark as closed those slots that start at or after the current selected slot.
        for (var i = 0; i < slots.length; i++) {
          final currentSlot = slots[i];
          final currentTime = DateTime(
            _selectedDate.year,
            _selectedDate.month,
            _selectedDate.day,
            currentSlot.hour,
            currentSlot.minute,
          );
          if (currentTime.isAfter(startTime.subtract(const Duration(minutes: 1))) && currentTime.isBefore(breakEnd)) {
            slots[i] = currentSlot.copyWith(isOpen: false);
          }
        }
      }

      // Update the availability document.
      batch.set(
        availabilityRef,
        {
          'weekStart': Timestamp.fromDate(weekStart),
          'slots': slots.map((s) => s.toMap()).toList(),
          'lastUpdated': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      await batch.commit();

      // Clear selections after a successful booking.
      specialistProvider.clearSelections();
      setState(() => _selectedSlots.clear());
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SuccessScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking failed: $e')),
      );
    } finally {
      setState(() => isLoading = false);
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
            SizedBox(height: 32.h),
            // Date Selection Timeline
            EasyDateTimeLine(
              initialDate: _selectedDate,
              onDateChange: (selectedDate) {
                setState(() {
                  _selectedDate = selectedDate;
                  // When changing date, clear previous time slot and service selections.
                  _selectedSlots.clear();
                  Provider.of<SpecialistProvider>(context, listen: false).clearSelections();
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
                  dayNumStyle: appTextStyle20(AppColors.newThirdGrayColor),
                  dayStrStyle: appTextStyle16400(AppColors.newThirdGrayColor),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.appBGColor, width: 2.w),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                activeDayStyle: DayStyle(
                  dayStrStyle: appTextStyle16400(AppColors.newThirdGrayColor),
                  monthStrStyle: appTextStyle20(AppColors.newThirdGrayColor),
                  dayNumStyle: appTextStyle20(AppColors.newThirdGrayColor),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.5),
                    border: Border.all(color: AppColors.appBGColor, width: 2.w),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            // Time Slots Section
            Text(
              'Available Time Slots',
              style: appTextStyle24500(AppColors.mainBlackTextColor),
            ),
            SizedBox(height: 20.h),
            FutureBuilder<List<TimeSlot>>(
              future: _getAvailability(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator.adaptive());
                }
                final slots = snapshot.data ?? [];
                if (slots.isEmpty) {
                  return Center(child: Text('No available time slots'));
                }
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: slots.map((slot) {
                    return Tooltip(
                      message: 'Select for ${Provider.of<SpecialistProvider>(context, listen: false).totalDuration} min service',
                      child: TimeSlotButton(
                        time: _formatTime(slot.hour, slot.minute),
                        isSelected: _selectedSlots.any((s) => s.day == slot.day && s.hour == slot.hour && s.minute == slot.minute),
                        onPressed: () {
                          // Before adding a time slot, ensure at least one service is selected.
                          final provider = Provider.of<SpecialistProvider>(context, listen: false);
                          if (provider.selectedServices.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please select at least one service first')),
                            );
                            return;
                          }
                          setState(() {
                            final existingIndex = _selectedSlots.indexWhere((s) => s.day == slot.day && s.hour == slot.hour && s.minute == slot.minute);
                            if (existingIndex != -1) {
                              _selectedSlots.removeAt(existingIndex);
                            } else {
                              _selectedSlots.add(slot);
                            }
                          });
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            SizedBox(height: 24),
            // Services Section
            Text(
              LocaleData.services.getString(context),
              style: appTextStyle24500(AppColors.mainBlackTextColor),
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('users').doc(widget.specialistId).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final userData = snapshot.data!.data() as Map<String, dynamic>;
                final services = List<Map<String, dynamic>>.from(userData['services'] ?? []);
                if (services.isEmpty) {
                  return Center(child: Text('Specialist has not listed any services'));
                }
                return Column(
                  children: services.map((service) {
                    return InkWell(onTap: () {
                      Provider.of<SpecialistProvider>(context, listen: false).toggleServiceSelection(service);
                    }, child: Consumer<SpecialistProvider>(
                      builder: (context, provider, _) {
                        final isSelected = provider.isServiceSelected(service['service']);
                        return InkWell(
                          onTap: () {
                            provider.toggleServiceSelection(service);
                          },
                          child: Container(
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(vertical: 4.h),
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.appBGColor.withOpacity(0.2) : Colors.transparent,
                              border: Border.all(
                                color: isSelected ? AppColors.appBGColor : Colors.grey.shade300,
                                width: 1.5.w,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(
                                  isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                                  color: isSelected ? AppColors.appBGColor : Colors.grey,
                                ),
                                SizedBox(width: 12.w),
                                SizedBox(
                                  width: 270.w,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        service['service'] ?? 'Service',
                                        style: appTextStyle14(AppColors.mainBlackTextColor).copyWith(fontWeight: FontWeight.w500),
                                      ),
                                      Spacer(),
                                      Text(
                                        '--',
                                        style: appTextStyle14(AppColors.mainBlackTextColor).copyWith(fontWeight: FontWeight.w500),
                                      ),
                                      Spacer(),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            formatPrice(service['price']),
                                            style: appTextStyle12K(AppColors.newThirdGrayColor).copyWith(fontWeight: FontWeight.w800),
                                          ),
                                          Text(
                                            '${service['duration']} mins',
                                            style: appTextStyle10(AppColors.newThirdGrayColor),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ));
                  }).toList(),
                );
              },
            ),
            SizedBox(height: 24),
            // Address Section
            Text(
              'Address of Meeting',
              style: appTextStyle24500(AppColors.mainBlackTextColor),
            ),
            SizedBox(height: 8),
            Consumer2<AddressProvider, SpecialistProvider>(builder: (context, addressProvider, userProvider, _) {
              if (userProvider.specialistModel?.isAvailable == false) {
                return Center(child: Text('Specialist is not available at the moment'));
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AddressCard(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    title: 'Your Address',
                    address: addressProvider.selectedAddress != null ? addressProvider.selectedAddress!.details : 'Tap to select address',
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AddressCard(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        title: 'Client Address',
                        address: addressProvider.selectedAddress != null ? addressProvider.selectedAddress!.details : 'No address added',
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                ],
              );
            }),

            // (Optional) An extra button to add more time slots, if needed.
            InkWell(
              onTap: _showAddressBottomSheet,
              child: Container(
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
                  ),
                ),
              ),
            ),
            SizedBox(height: 54.h),
            // Booking Button
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
                    onPressed: () => _bookAppointment(
                      provider.specialistModel!.firstName,
                      provider.specialistModel!.lastName,
                    ),
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

  void _showAddressBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SelectAddressBottomSheet(addressController: _addressController),
    );
  }
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
        backgroundColor: isSelected ? AppColors.appBGColor : AppColors.whiteColor,
        padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 8.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.dg),
        ),
        side: BorderSide(
          color: isSelected ? AppColors.mainBlackTextColor : AppColors.appBGColor,
          width: 2.w,
        ),
      ),
      child: Text(
        time,
        style: appTextStyle16500(
          isSelected ? AppColors.mainBlackTextColor : AppColors.newThirdGrayColor,
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.dg),
        border: Border.all(color: AppColors.appBGColor, width: 2.w),
      ),
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4.h),
          Text(address, style: appTextStyle12K(AppColors.newThirdGrayColor)),
        ],
      ),
    );
  }
}
