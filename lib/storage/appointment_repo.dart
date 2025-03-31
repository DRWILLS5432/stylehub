import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stylehub/screens/specialist_pages/model/appointment_model.dart';

class AppointmentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch appointments by user role (client or specialist)
  Future<List<AppointmentModel>> fetchAppointments({
    required String userId,
    required bool isSpecialist,
  }) async {
    try {
      // Determine the field to query based on user type
      final field = isSpecialist ? 'specialistId' : 'clientId';

      final query = _firestore.collection('appointments').where(field, isEqualTo: userId).orderBy('date', descending: false); // Changed to ascending

      final snapshot = await query.get();

      // Convert to models and reverse to show newest first in UI
      final appointments = snapshot.docs.map((doc) => AppointmentModel.fromMap(doc.data())).toList();

      return appointments.reversed.toList(); // Reverse the list
    } catch (e) {
      debugPrint('Error fetching appointments: $e');
      if (e is FirebaseException && e.code == 'failed-precondition') {
        debugPrint('You need to create a Firestore index for this query');
      }
      return [];
    }
  }
  // Future<List<AppointmentModel>> fetchAppointments({
  //   required String userId,
  //   required bool isSpecialist,
  // }) async {
  //   try {
  //     QuerySnapshot snapshot = await _firestore.collection('appointments').where(isSpecialist ? 'specialistId' : 'clientId', isEqualTo: userId).orderBy('date', descending: true).get();

  //     return snapshot.docs.map((doc) => AppointmentModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
  //   } catch (e) {
  //     // print('Error fetching appointments: $e');
  //     return [];
  //   }
  // }

  // Cancel an appointment using the AppointmentRepository class
  Future<void> deleteAppointment(String appointmentId) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).delete();
    } catch (e) {
      throw Exception('Failed to delete appointment: $e');
    }
  }
}
