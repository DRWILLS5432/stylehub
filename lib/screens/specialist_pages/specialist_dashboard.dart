import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stylehub/constants/app/app_colors.dart';
import 'package:stylehub/constants/app/textstyle.dart';
import 'package:stylehub/constants/localization/locales.dart';

class SpecialistDashboard extends StatefulWidget {
  const SpecialistDashboard({super.key});

  @override
  State<SpecialistDashboard> createState() => _SpecialistDashboardState();
}

class _SpecialistDashboardState extends State<SpecialistDashboard> {
  String? userName;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        body: SingleChildScrollView(
          child: SafeArea(
            child: Container(
              color: AppColors.appBGColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 255, 255, 255),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12.0),
                        bottomRight: Radius.circular(12.0),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/specialist_profile'),
                          child: Hero(
                            tag: '1',
                            child: Container(
                              padding: EdgeInsets.all(4.dg),
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(100.dg), color: AppColors.appBGColor),
                              child: CircleAvatar(
                                radius: 50.dg,
                                backgroundColor: Colors.grey[200],
                                backgroundImage: _imageBytes != null ? MemoryImage(_imageBytes!) : null,
                                child: _imageBytes == null ? Icon(Icons.add_a_photo, size: 30, color: Colors.grey[600]) : null,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.03,
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 10.h),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(LocaleData.welcomeBack.getString(context),
                                      style: mediumTextStyle25(
                                        AppColors.newGrayColor,
                                      )),
                                  Text(userName ?? '', style: appTextStyle20(AppColors.newGrayColor)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.only(bottom: 30.h),
                            child: Image.asset(
                              'assets/images/Bell.png',
                              height: 26.h,
                              width: 27.w,
                            )),
                      ],
                    ),
                  ),
                  // SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    height: 150.h,
                    padding: EdgeInsets.only(
                      left: 16.w,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xFFD7D1BE),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4.h),
                        Text(
                          LocaleData.category.getString(context),
                          style: appTextStyle18(AppColors.newThirdGrayColor),
                          // style: TextStyle(fontSize: 18, fontFamily: 'InstrumentSans'),
                        ),
                        SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildCategoryIcon('Haircut', 'assets/haircut_icon.png'),
                              _buildCategoryIcon('Shave', 'assets/shave_icon.png'),
                              _buildCategoryIcon('Facials', 'assets/facials_icon.png'),
                              _buildCategoryIcon('Manicure', 'assets/manicure_icon.png'),
                              _buildCategoryIcon('Chauffeur', 'assets/manicure_icon.png'),
                              _buildCategoryIcon('Cleaning', 'assets/manicure_icon.png'),
                              _buildCategoryIcon('Manicure', 'assets/manicure_icon.png'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12.0),
                        topRight: Radius.circular(12.0),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 205.w,
                              child: Text(
                                LocaleData.findProfessional.getString(context),
                                style: appTextStyle16400(AppColors.newThirdGrayColor),
                                overflow: TextOverflow.visible,
                                softWrap: true,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(context, '/filter_screen'),
                              child: Image.asset(
                                'assets/categ_settings.png',
                                width: 24,
                                height: 24,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        buildProfessionalCard(context, 'John Doe', 'Barber', 4.5, onTap: () {
                          Navigator.pushNamed(context, '/specialist_detail_screen');
                        }),
                        buildProfessionalCard(context, 'Jane Smith', 'Hairstylist', 4.8, onTap: () {
                          Navigator.pushNamed(context, '/specialist_detail_screen');
                        }),
                        SizedBox(height: 70),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildCategoryIcon(String label, String assetPath) {
  return InkWell(
    onTap: () {},
    splashColor: AppColors.whiteColor,
    highlightColor: AppColors.newGrayColor,
    overlayColor: WidgetStateProperty.all(Colors.green),
    child: Padding(
      padding: EdgeInsets.only(right: 20.w),
      child: Column(
        children: [
          Image.asset(assetPath, width: 70.w, height: 70.h),
          SizedBox(height: 8.h),
          Text(
            label, style: appTextStyle15(AppColors.newThirdGrayColor),
            //  TextStyle(fontSize: 16, fontFamily: 'InstrumentSans'),
          ),
        ],
      ),
    ),
  );
}

Widget buildProfessionalCard(context, String name, String profession, double rating, {Function()? onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      color: Color(0xFFD7D1BE),
      child: Padding(
        padding: EdgeInsets.only(left: 17.w, right: 17.h, top: 29.h, bottom: 12.h),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.dg),
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(100.dg),
                  ),
                  child: CircleAvatar(
                    radius: 60.dg,
                    backgroundImage: AssetImage('assets/master1.png'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(name, style: appTextStyle20(AppColors.newThirdGrayColor)),
                      Text(
                        profession,
                        style: appTextStyle15(AppColors.newThirdGrayColor),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: List.generate(
                          5,
                          (index) => Icon(
                            index < rating ? Icons.star : Icons.star_border,
                            color: const Color.fromARGB(255, 2, 1, 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_pin, color: AppColors.newThirdGrayColor),
                    Text("70m", style: appTextStyle15(AppColors.newThirdGrayColor)),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/specialist_detail_screen');
                  },
                  child: Text(
                    LocaleData.view.getString(context),
                    style: appTextStyle14(AppColors.newThirdGrayColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
