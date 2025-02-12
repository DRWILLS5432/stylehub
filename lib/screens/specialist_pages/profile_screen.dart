import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:stylehub/constants/app/app_colors.dart';
import 'package:stylehub/constants/app/textstyle.dart';
import 'package:stylehub/constants/localization/locales.dart';
import 'package:stylehub/onboarding_page/onboarding_screen.dart';
import 'package:stylehub/screens/specialist_pages/provider/specialist_provider.dart';
import 'package:stylehub/screens/specialist_pages/widgets/settings_widget.dart';
import 'package:stylehub/screens/specialist_pages/widgets/update_service_widget.dart';

class SpecialistProfileScreen extends StatefulWidget {
  const SpecialistProfileScreen({super.key});

  @override
  State<SpecialistProfileScreen> createState() => _SpecialistProfileScreenState();
}

class _SpecialistProfileScreenState extends State<SpecialistProfileScreen> {
  String? userName;
  Uint8List? _imageBytes;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    Provider.of<SpecialistProvider>(context, listen: false).fetchSpecialistData();
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        // Use the data() method to access the document's data as a Map
        Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

        if (userData != null) {
          setState(() {
            // Safely access the 'firstName' field
            userName = userData['firstName'] as String?;

            // Safely access the 'profileImage' field
            String? base64Image = userData['profileImage'] as String?;
            if (base64Image != null) {
              try {
                _imageBytes = base64Decode(base64Image);
              } catch (e) {
                // print("Error decoding base64 image: $e");
                // Handle the error, e.g., set a default image
              }
            }
          });
        }
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      Uint8List imageBytes = await pickedFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      setState(() {
        _imageBytes = imageBytes;
      });
      await _saveImageToFirestore(base64Image);
    }
  }

  Future<void> _saveImageToFirestore(String base64Image) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'profileImage': base64Image,
      }, SetOptions(merge: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
      ),
      body: SafeArea(
        child: Consumer<SpecialistProvider>(builder: (context, provider, _) {
          final userData = provider.specialistModel;
          // final fullName = "${userData?.firstName} ${userData?.lastName.toString()}";

          if (userData == null) {
            return Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 20),
                  Stack(
                    children: [
                      Hero(
                        tag: '1',
                        child: Container(
                          padding: EdgeInsets.all(3.dg),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(100.dg), color: AppColors.appBGColor),
                          child: CircleAvatar(
                            radius: 65.dg,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: _imageBytes != null ? MemoryImage(_imageBytes!) : null,
                            child: _imageBytes == null ? Icon(Icons.add_a_photo, size: 30, color: Colors.grey[600]) : null,
                          ),
                        ),
                      ),
                    ],
                  ),

                  TextButton(onPressed: _pickImage, child: Text(LocaleData.changeProfilePics.getString(context), style: appTextStyle14(AppColors.appGrayTextColor))),
                  SizedBox(width: 29.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_pin, color: AppColors.newThirdGrayColor),
                      SizedBox(width: 2.w),
                      Text(
                        'enina 36A Entrance 4',
                        style: appTextStyle12K(AppColors.newThirdGrayColor),
                      ),
                      SizedBox(width: 5.w),
                      Container(
                        // padding: EdgeInsets.all(5.dg),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(50.dg), border: Border.all(color: AppColors.mainBlackTextColor)),
                        child: CircleAvatar(
                          backgroundColor: AppColors.mainBlackTextColor,
                          radius: 10.dg,
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: AppColors.whiteColor,
                            size: 16.h,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 46),
                  Column(
                    children: [
                      ProfileTiles(
                          onTap: () => Navigator.pushNamed(context, '/personal_details'),
                          title: LocaleData.personalDetails.getString(context),
                          subtitle: LocaleData.editProfileDetail.getString(context),
                          icon: 'assets/images/User.png'),
                      ProfileTiles(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateServiceWidget())),
                          title: LocaleData.specialistDetails.getString(context),
                          subtitle: LocaleData.updateServiceDetail.getString(context),
                          icon: 'assets/images/Scissors.png'),
                      ProfileTiles(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsWidget())),
                          title: LocaleData.appSettings.getString(context),
                          subtitle: LocaleData.updateSettings.getString(context),
                          icon: 'assets/images/Settings.png')
                    ],
                  ),
                  SizedBox(height: 51.h),
                  SizedBox(
                    width: 212.w,
                    height: 45.h,
                    child: ReusableButton(
                        bgColor: AppColors.whiteColor,
                        width: 212.w,
                        height: 45.h,
                        text: _isLoading
                            ? SizedBox(
                                height: 20.h,
                                width: 20.w,
                                child: CircularProgressIndicator.adaptive(
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.whiteColor),
                                  strokeWidth: 3.dg,
                                ),
                              )
                            : Text(LocaleData.logout.getString(context), style: mediumTextStyle25(AppColors.mainBlackTextColor)),
                        onPressed: () {
                          setState(() => _isLoading = true);

                          FirebaseAuth.instance.signOut();
                          setState(() => _isLoading = false);
                        }),
                  ),
                  SizedBox(height: 20),

                  /// Here is the logout button
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class ProfileTiles extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final String? icon;
  const ProfileTiles({super.key, required this.title, required this.subtitle, this.onTap, this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 22.h, left: 30.w, right: 30.w),
        padding: EdgeInsets.only(
          right: 10.w,
          left: 25.w,
          top: 25.h,
        ),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.dg), color: AppColors.appBGColor),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(height: 50.h, width: 50.w, child: Image.asset(icon.toString())),
                SizedBox(width: 5.w),
                SizedBox(
                  width: 180.w,
                  child: Text(
                    title,
                    style: appTextStyle205(AppColors.newThirdGrayColor),
                  ),
                ),
              ],
            ),

            // subtitle: Text(subtitle, style: appTextStyle10(AppColors.mainBlackTextColor)),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  // padding: EdgeInsets.all(5.dg),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(50.dg), border: Border.all(color: AppColors.mainBlackTextColor)),
                  child: CircleAvatar(
                    backgroundColor: AppColors.appBGColor,
                    radius: 12.dg,
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.mainBlackTextColor,
                      size: 16.h,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 12.h,
            )
          ],
        ),
      ),
    );
  }
}
