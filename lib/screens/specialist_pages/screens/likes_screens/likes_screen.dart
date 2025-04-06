import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stylehub/constants/app/app_colors.dart';
import 'package:stylehub/constants/app/textstyle.dart';
import 'package:stylehub/constants/localization/locales.dart';
import 'package:stylehub/screens/specialist_pages/model/specialist_model.dart';
import 'package:stylehub/screens/specialist_pages/specialist_detail_screen.dart';
import 'package:stylehub/storage/fire_store_method.dart';
import 'package:stylehub/storage/likes_method.dart';

class LikesScreen extends StatelessWidget {
  const LikesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        automaticallyImplyLeading: false,
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
        stream: LikeService().getFavorites(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No favorites yet'));
          }

          final favorites = snapshot.data!.docs;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final favoriteData = favorites[index].data() as Map<String, dynamic>;

                    // Create a simplified specialist model from the favorite data
                    final specialist = SpecialistModel(
                      userId: favoriteData['specialistId'],
                      firstName: favoriteData['specialistName'],
                      lastName: favoriteData['specialistLastName'],
                      profileImage: favoriteData['profileImage'],
                      role: favoriteData['role'], email: '', bio: '', experience: '', city: '', phone: '', categories: [], images: [], services: [],
                      // Other fields can be added if needed
                    );

                    return FutureBuilder<double>(
                      future: FireStoreMethod().getAverageRating(specialist.userId),
                      builder: (context, ratingSnapshot) {
                        if (ratingSnapshot.connectionState == ConnectionState.waiting) {
                          return SizedBox.shrink();
                        }

                        double averageRating = ratingSnapshot.data ?? 0.0;

                        return buildProfessionalCard(context, specialist, averageRating);
                      },
                    );
                  },
                ),
              ),
              SizedBox(
                height: 70.h,
              )
            ],
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
