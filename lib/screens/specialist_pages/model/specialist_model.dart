import 'package:cloud_firestore/cloud_firestore.dart';

class SpecialistModel {
  final String userId;
  final String email;
  final String firstName;
  final String lastName;
  final String? profileImage;
  final String role;

  SpecialistModel({
    required this.userId,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.profileImage,
    required this.role,
  });

  // Factory constructor to create a SpecialistModel from a Firestore document
  factory SpecialistModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SpecialistModel(
      userId: doc.id,
      email: data['email'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      profileImage: data['profileImage'] ?? '',
      role: data['role'] ?? '',
    );
  }

  factory SpecialistModel.fromSnap(DocumentSnapshot snap) {
    Map<String, dynamic> data = snap.data() as Map<String, dynamic>;
    return SpecialistModel(
      userId: snap.id,
      email: data['email'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      role: data['role'] ?? '',
      profileImage: data['profileImage'] ?? '',
    );
  }

  // Convert SpecialistModel to a Map (useful for Firestore updates)
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'profileImage': profileImage,
      'role': role,
    };
  }

// CopyWith method for updating properties easily
  SpecialistModel copyWith({
    String? userId,
    String? email,
    String? firstName,
    String? lastName,
    String? profileImage,
    String? role,
  }) {
    return SpecialistModel(
      userId: userId.toString(),
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profileImage: profileImage ?? this.profileImage,
      role: role ?? this.role,
    );
  }
}
// class SpecialistModel {
//   final String email;
//   final String firstName;
//   final String lastName;
//   final String role;
//   final String profileImage;

//   SpecialistModel({
//     required this.email,
//     required this.firstName,
//     required this.lastName,
//     required this.role,
//     required this.profileImage,
//   });

//   // Factory method to create a SpecialistModel from a Firebase document snapshot
//   factory SpecialistModel.fromMap(Map<String, dynamic> data) {
//     return SpecialistModel(
//       email: data['email'] ?? '', // Provide a default value if null
//       firstName: data['firstName'] ?? '',
//       lastName: data['lastName'] ?? '',
//       role: data['role'] ?? 'Customer', // Default role
//       profileImage: data['profileImage'] ?? '',
//     );
//   }

//   // Convert a SpecialistModel object into a Map to store in Firebase
//   Map<String, dynamic> toMap() {
//     return {'email': email, 'firstName': firstName, 'lastName': lastName, 'role': role, 'profileImage': profileImage};
//   }

//   //Optional :  Create a copy of the user model.
//   SpecialistModel copyWith({
//     String? email,
//     String? firstName,
//     String? lastName,
//     String? role,
//     required String profileImage,
//   }) {
//     return SpecialistModel(
//       email: email ?? this.email,
//       firstName: firstName ?? this.firstName,
//       lastName: lastName ?? this.lastName,
//       role: role ?? this.role,
//       profileImage: profileImage,
//     );
//   }
// }
