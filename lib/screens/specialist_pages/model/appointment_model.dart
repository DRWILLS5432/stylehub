import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String appointmentId;
  final String clientFirstName;
  final String clientLastName;
  final String specialistId;
  final String clientId;
  final String address;
  final DateTime date;
  final String status;
  String? specialistName;

  AppointmentModel({
    required this.appointmentId,
    required this.clientFirstName,
    required this.clientLastName,
    required this.specialistId,
    required this.clientId,
    required this.address,
    required this.date,
    required this.status,
    this.specialistName,
  });

  factory AppointmentModel.fromMap(Map<String, dynamic> data) {
    return AppointmentModel(
      appointmentId: data['appointmentId'] ?? '',
      clientFirstName: data['clientFirstName'] ?? '',
      clientLastName: data['clientLastName'] ?? '',
      specialistId: data['specialistId'] ?? '',
      clientId: data['clientId'] ?? '',
      address: data['address'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      status: data['status'] ?? 'booked',
    );
  }
}
