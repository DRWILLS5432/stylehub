import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stylehub/constants/app/app_colors.dart';
import 'package:stylehub/constants/app/textstyle.dart';
import 'package:stylehub/onboarding_page/onboarding_screen.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  bool isChecked = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(backgroundColor: AppColors.whiteColor),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter',
                    style: appTextStyle24(AppColors.mainBlackTextColor),
                  ),
                  Image.asset(
                    'assets/categ_settings.png',
                    width: 24,
                    height: 24,
                  ),
                ],
              ),
              SizedBox(
                height: 60.h,
              ),
              Text(
                'Proximinty',
                style: appTextStyle20(AppColors.mainBlackTextColor),
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nearest specialists',
                    style: appTextStyle20(AppColors.newGrayColor),
                  ),
                  Checkbox(
                    value: isChecked,
                    onChanged: (bool? newValue) => setState(() {
                      newValue = isChecked;
                    }),
                  )
                ],
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Specialists in city',
                    style: appTextStyle20(AppColors.newGrayColor),
                  ),
                  Checkbox(
                    value: false,
                    onChanged: (bool? newValue) => setState(() {}),
                  )
                ],
              ),
              SizedBox(height: 40.h),
              Text(
                'Rating',
                style: appTextStyle20(AppColors.mainBlackTextColor),
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Highest Rating',
                    style: appTextStyle20(AppColors.newGrayColor),
                  ),
                  Checkbox(
                    value: false,
                    onChanged: (bool? newValue) => setState(() {}),
                  )
                ],
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Medium Rating',
                    style: appTextStyle20(AppColors.newGrayColor),
                  ),
                  Checkbox(
                    value: false,
                    onChanged: (bool? newValue) => setState(() {}),
                  )
                ],
              ),
              SizedBox(height: 112.h),
              Center(
                child: SizedBox(
                  width: 272.w,
                  child: ReusableButton(
                    height: 60.h,
                    color: AppColors.appBGColor,
                    bgColor: AppColors.grayColor,
                    text: Text(
                      'Apply Filter',
                      style: appTextStyle16(AppColors.newThirdGrayColor),
                    ),
                    onPressed: () {},
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
