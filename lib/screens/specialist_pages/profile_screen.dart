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
          final fullName = "${userData?.firstName} ${userData?.lastName.toString()}";

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
                      Container(
                        padding: EdgeInsets.all(3.dg),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(100.dg), color: AppColors.appBGColor),
                        child: CircleAvatar(
                          radius: 65.dg,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: _imageBytes != null ? MemoryImage(_imageBytes!) : null,
                          child: _imageBytes == null ? Icon(Icons.add_a_photo, size: 30, color: Colors.grey[600]) : null,
                        ),
                      ),
                      Positioned(
                          bottom: 0,
                          right: 5.w,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: CircleAvatar(
                                backgroundColor: AppColors.appBGColor,
                                child: Icon(
                                  Icons.add_a_photo,
                                  size: 24.h,
                                  color: AppColors.mainBlackTextColor,
                                )),
                          ))
                    ],
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(fullName, style: appTextStyle23800(AppColors.mainBlackTextColor)),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(userData.email, style: appTextStyle14(AppColors.mainBlackTextColor)),
                  ),
                  SizedBox(height: 20),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                    width: double.infinity,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.dg), color: AppColors.appBGColor),
                    child: Column(
                      children: [
                        ProfileTiles(
                          onTap: () => showModalBottomSheet(context: context, builder: (context) => SettingsWidget()),
                          title: LocaleData.editProfile.getString(context),
                          subtitle: LocaleData.editProfileDetail.getString(context),
                        ),
                        ProfileTiles(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateServiceWidget())),
                          title: LocaleData.updateService.getString(context),
                          subtitle: LocaleData.updateServiceDetail.getString(context),
                          icon: Icons.update,
                        ),
                        ProfileTiles(
                          onTap: () => showModalBottomSheet(context: context, builder: (context) => SettingsWidget()),
                          title: LocaleData.settings.getString(context),
                          subtitle: LocaleData.updateSettings.getString(context),
                          icon: Icons.settings,
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 40.h),

                  /// Here is the logout button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: _isLoading ? AppColors.grayColor : AppColors.mainBlackTextColor,
                        minimumSize: Size(
                          double.infinity,
                          50.h,
                        )),
                    child: _isLoading
                        ? SizedBox(
                            height: 20.h,
                            width: 20.w,
                            child: CircularProgressIndicator.adaptive(
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.whiteColor),
                              strokeWidth: 3.dg,
                            ),
                          )
                        : Text(
                            LocaleData.logout.getString(context),
                            style: appTextStyle16(AppColors.whiteColor),
                          ),
                    onPressed: () {
                      setState(() => _isLoading = true);

                      FirebaseAuth.instance.signOut();
                      setState(() => _isLoading = false);
                    },
                  ),
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
  final IconData? icon;
  const ProfileTiles({super.key, required this.title, required this.subtitle, this.onTap, this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: 10.w, left: 10.h, top: 10.h),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.dg), color: AppColors.whiteColor),
        child: ListTile(
            leading: CircleAvatar(backgroundColor: AppColors.grayColor, child: Icon(icon ?? Icons.person, color: AppColors.mainBlackTextColor)),
            title: Text(
              title,
              style: appTextStyle16(AppColors.mainBlackTextColor),
            ),
            subtitle: Text(subtitle, style: appTextStyle10(AppColors.mainBlackTextColor)),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: AppColors.mainBlackTextColor,
              size: 16.h,
            )),
      ),
    );
  }
}
