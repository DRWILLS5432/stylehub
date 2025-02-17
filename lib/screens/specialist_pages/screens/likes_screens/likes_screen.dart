import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stylehub/constants/app/app_colors.dart';
import 'package:stylehub/constants/app/textstyle.dart';
import 'package:stylehub/constants/localization/locales.dart';
import 'package:stylehub/screens/specialist_pages/specialist_dashboard.dart';

class LikesScreen extends StatelessWidget {
  const LikesScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: Padding(
        padding: EdgeInsets.all(20.dg),
        child: Column(
          children: [
            buildProfessionalCard(context, 'John Doe', 'Barber', 4.5),
          ],
        ),
      ),
    );
  }
}
