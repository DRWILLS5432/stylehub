import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stylehub/constants/app/app_colors.dart';
import 'package:stylehub/constants/app/textstyle.dart';
import 'package:stylehub/constants/localization/locales.dart';
import 'package:stylehub/screens/specialist_pages/model/specialist_model.dart';
import 'package:stylehub/screens/specialist_pages/specialist_detail_screen.dart';
import 'package:stylehub/storage/fire_store_method.dart';

class LikesScreen extends StatelessWidget {
  const LikesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        centerTitle: false,
        title: Text(
          LocaleData.likes.getString(context),
          style: appTextStyle24(AppColors.newThirdGrayColor),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20.w),
            child: Icon(Icons.favorite),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user.uid).collection('likes').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No likes yet'));
          }

          final likes = snapshot.data!.docs;

          return ListView.builder(
            itemCount: likes.length,
            itemBuilder: (context, index) {
              final likeData = likes[index].data() as Map<String, dynamic>?;

              if (likeData == null) {
                return SizedBox.shrink(); // Skip if data is null
              }

              String userId = likeData['userId'] ?? ''; // Ensure non-null userId
              if (userId.isEmpty) return SizedBox.shrink(); // Skip invalid entries

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox.shrink();
                  }

                  if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                    return SizedBox.shrink();
                  }

                  var userDoc = userSnapshot.data!;
                  SpecialistModel likedUser = SpecialistModel.fromSnap(userDoc);

                  return FutureBuilder<double>(
                    future: FireStoreMethod().getAverageRating(likedUser.userId),
                    builder: (context, ratingSnapshot) {
                      if (ratingSnapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox.shrink();
                      }

                      double averageRating = ratingSnapshot.data ?? 0.0;

                      return buildProfessionalCard(context, likedUser, averageRating);
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

Widget buildProfessionalCard(
  BuildContext context,
  SpecialistModel user,
  double averageRating,
) {
  return Card(
    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
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
                  backgroundImage: user.profileImage != null ? MemoryImage(base64Decode(user.profileImage!)) : AssetImage('assets/master1.png') as ImageProvider,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(user.fullName, style: appTextStyle20(AppColors.newThirdGrayColor)),
                    Text(
                      user.role,
                      style: appTextStyle15(AppColors.newThirdGrayColor),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < averageRating.floor() ? Icons.star : Icons.star_border,
                          color: Colors.black,
                          size: 20,
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SpecialistDetailScreen(
                        userId: user.userId,
                      ),
                    ),
                  );
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
  );
}
