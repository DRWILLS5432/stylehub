import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stylehub/screens/specialist_pages/model/specialist_model.dart';

class SpecialistProvider extends ChangeNotifier {
  SpecialistModel? _specialistModel;

  SpecialistModel? get specialistModel => _specialistModel;

  // Fetch user data method
  Future<void> fetchSpecialistData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          // Convert the document data to a SpecialistModel object using fromFirestore
          _specialistModel = SpecialistModel.fromFirestore(userDoc);
          print(_specialistModel!.profileImage.toString());
        } else {
          // Handle the case where the user document doesn't exist
          _specialistModel = null;
        }
      } catch (error) {
        // Handle any errors that occur during data fetching
        print("Error fetching specialist data: $error");
        _specialistModel = null;
      }
      notifyListeners(); // Notify listeners after fetching data
    } else {
      // Handle the case where the user is not authenticated
      _specialistModel = null;
      notifyListeners();
    }
  }

  Future<void> updateProfileImage(String base64Image) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'profileImage': base64Image,
        });

        // Update the local SpecialistModel with the new image
        _specialistModel = _specialistModel?.copyWith(profileImage: base64Image);
        notifyListeners(); // Notify listeners after updating
      } catch (e) {
        // print("Error updating profile image: $e");
      }
    }
  }

  String? getProfileImage() {
    return _specialistModel?.profileImage;
  }
  
}
