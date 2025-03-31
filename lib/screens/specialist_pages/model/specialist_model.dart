// import 'package:cloud_firestore/cloud_firestore.dart';

// class SpecialistModel {
//   final String userId;
//   final String email;
//   final String firstName;
//   final String lastName;
//   final String? profileImage;
//   final String role;

//   SpecialistModel({
//     required this.userId,
//     required this.email,
//     required this.firstName,
//     required this.lastName,
//     this.profileImage,
//     required this.role,
//   });

//   // Factory constructor to create a SpecialistModel from a Firestore document
//   factory SpecialistModel.fromFirestore(DocumentSnapshot doc) {
//     Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//     return SpecialistModel(
//       userId: doc.id,
//       email: data['email'] ?? '',
//       firstName: data['firstName'] ?? '',
//       lastName: data['lastName'] ?? '',
//       profileImage: data['profileImage'] ?? '',
//       role: data['role'] ?? '',
//     );
//   }

//   factory SpecialistModel.fromSnap(DocumentSnapshot snap) {
//     Map<String, dynamic> data = snap.data() as Map<String, dynamic>;
//     return SpecialistModel(
//       userId: snap.id,
//       email: data['email'] ?? '',
//       firstName: data['firstName'] ?? '',
//       lastName: data['lastName'] ?? '',
//       role: data['role'] ?? '',
//       profileImage: data['profileImage'] ?? '',
//     );
//   }

//   // Convert SpecialistModel to a Map (useful for Firestore updates)
//   Map<String, dynamic> toMap() {
//     return {
//       'userId': userId,
//       'email': email,
//       'firstName': firstName,
//       'lastName': lastName,
//       'profileImage': profileImage,
//       'role': role,
//     };
//   }

// // CopyWith method for updating properties easily
//   SpecialistModel copyWith({
//     String? userId,
//     String? email,
//     String? firstName,
//     String? lastName,
//     String? profileImage,
//     String? role,
//   }) {
//     return SpecialistModel(
//       userId: userId.toString(),
//       email: email ?? this.email,
//       firstName: firstName ?? this.firstName,
//       lastName: lastName ?? this.lastName,
//       profileImage: profileImage ?? this.profileImage,
//       role: role ?? this.role,
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';

class SpecialistModel {
  final String userId;
  final String email;
  final String firstName;
  final String lastName;
  final String? profileImage;
  final String role;
  final String bio;
  final String experience;
  final String city;
  final String phone;
  final List<String> categories;
  final List<String> images;
  final List<Map<String, dynamic>> services;

  SpecialistModel({
    required this.userId,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.profileImage,
    required this.role,
    required this.bio,
    required this.experience,
    required this.city,
    required this.phone,
    required this.categories,
    required this.images,
    required this.services,
  });

  /// Creates a SpecialistModel from a Firestore document
  factory SpecialistModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SpecialistModel(
      userId: doc.id,
      email: data['email'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      profileImage: data['profileImage'],
      role: data['role'] ?? 'Stylist',
      bio: data['bio'] ?? 'No bio available',
      experience: data['experience'] ?? 'No experience info',
      city: data['city'] ?? '',
      phone: data['phone'] ?? '',
      categories: List<String>.from(data['categories'] ?? []),
      images: List<String>.from(data['images'] ?? []),
      services: List<Map<String, dynamic>>.from(data['services'] ?? []),
    );
  }

  /// Alternative constructor (kept for backward compatibility)
  factory SpecialistModel.fromSnap(DocumentSnapshot snap) {
    return SpecialistModel.fromFirestore(snap);
  }

  /// Converts the model to a Map for Firestore operations
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'profileImage': profileImage,
      'role': role,
      'bio': bio,
      'experience': experience,
      'city': city,
      'phone': phone,
      'categories': categories,
      'images': images,
      'services': services,
    };
  }

  /// Creates a copy of the model with updated fields
  SpecialistModel copyWith({
    String? userId,
    String? email,
    String? firstName,
    String? lastName,
    String? profileImage,
    String? role,
    String? bio,
    String? experience,
    String? city,
    String? phone,
    List<String>? categories,
    List<String>? images,
    List<Map<String, dynamic>>? services,
  }) {
    return SpecialistModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profileImage: profileImage ?? this.profileImage,
      role: role ?? this.role,
      bio: bio ?? this.bio,
      experience: experience ?? this.experience,
      city: city ?? this.city,
      phone: phone ?? this.phone,
      categories: categories ?? this.categories,
      images: images ?? this.images,
      services: services ?? this.services,
    );
  }

  /// Helper method to get full name
  String get fullName => '$firstName $lastName';

  /// Returns true if the specialist has a profile image
  bool get hasProfileImage => profileImage != null && profileImage!.isNotEmpty;

  /// Returns true if the specialist has services listed
  bool get hasServices => services.isNotEmpty;

  @override
  String toString() {
    return 'SpecialistModel(userId: $userId, email: $email, name: $fullName, role: $role)';
  }
}
