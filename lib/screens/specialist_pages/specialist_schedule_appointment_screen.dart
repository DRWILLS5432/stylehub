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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AppointmentScheduler extends StatefulWidget {
  const AppointmentScheduler({super.key});

  @override
  State<AppointmentScheduler> createState() => _AppointmentSchedulerState();
}

class _AppointmentSchedulerState extends State<AppointmentScheduler> {
  final Map<DayOfWeek, TimeRange> _freeTimes = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    // Initialize with default values for all days
    for (var day in DayOfWeek.values) {
      _freeTimes[day] = TimeRange(
        start: const TimeOfDay(hour: 8, minute: 0),
        end: const TimeOfDay(hour: 18, minute: 0),
      );
    }
  }

  Future<void> _saveFreeTimes() async {
    final userId = 'user_id'; // Replace with actual user ID
    final freeTimesMap = _freeTimes.map((key, value) => MapEntry(
          key.name,
          {'start': '${value.start.hour}:${value.start.minute}', 'end': '${value.end.hour}:${value.end.minute}'},
        ));

    await _firestore.collection('users').doc(userId).set({
      'freeTimes': freeTimesMap,
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Free Days and Times'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveFreeTimes,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: DayOfWeek.values.map((day) {
          return Card(
            elevation: 2.0,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    day.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Start Time: ${_freeTimes[day]!.start.format(context)}'),
                      ElevatedButton(
                        onPressed: () async {
                          TimeOfDay? selectedTime = await showTimePicker(
                            context: context,
                            initialTime: _freeTimes[day]!.start,
                          );
                          if (selectedTime != null) {
                            setState(() {
                              _freeTimes[day] = TimeRange(
                                start: selectedTime,
                                end: _freeTimes[day]!.end,
                              );
                            });
                          }
                        },
                        child: const Text('Select Start Time'),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('End Time: ${_freeTimes[day]!.end.format(context)}'),
                      ElevatedButton(
                        onPressed: () async {
                          TimeOfDay? selectedTime = await showTimePicker(
                            context: context,
                            initialTime: _freeTimes[day]!.end,
                          );
                          if (selectedTime != null) {
                            setState(() {
                              _freeTimes[day] = TimeRange(
                                start: _freeTimes[day]!.start,
                                end: selectedTime,
                              );
                            });
                          }
                        },
                        child: const Text('Select End Time'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Enum for Days of the Week
enum DayOfWeek { monday, tuesday, wednesday, thursday, friday, saturday, sunday }

// Class to hold Time Range information
class TimeRange {
  final TimeOfDay start;
  final TimeOfDay end;

  const TimeRange({required this.start, required this.end});
}
