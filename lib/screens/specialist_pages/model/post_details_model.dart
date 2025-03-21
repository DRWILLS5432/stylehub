import 'package:cloud_firestore/cloud_firestore.dart';

class PostServicesModel {
  final String userId;
  final String bio;
  final String phone;
  final String city;
  final List<Map<String, String>> services;
  final DateTime createdAt;

  PostServicesModel({
    required this.userId,
    required this.bio,
    required this.phone,
    required this.city,
    required this.services,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'bio': bio,
      'phone': phone,
      'city': city,
      'services': services,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Factory constructor to create a SpecialistModel from a Firestore document
  factory PostServicesModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PostServicesModel(
      userId: data['userId'],
      bio: data['bio'],
      phone: data['phone'],
      city: data['city'],
      services: List<Map<String, String>>.from(data['services']),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  static PostServicesModel fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return PostServicesModel(
      userId: snapshot['userId'],
      bio: snapshot['bio'],
      phone: snapshot['phone'],
      city: snapshot['city'],
      services: List<Map<String, String>>.from(snapshot['services']),
      createdAt: (snapshot['createdAt'] as Timestamp).toDate(),
    );
  }
}
