import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stylehub/constants/app/app_colors.dart';
import 'package:stylehub/constants/app/textstyle.dart';
import 'package:stylehub/constants/localization/locales.dart';
import 'package:stylehub/onboarding_page/onboarding_screen.dart';

class AppointmentScreen extends StatelessWidget {
  const AppointmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        centerTitle: false,
        title: Text(
          LocaleData.appointments.getString(context),
          style: appTextStyle24(AppColors.newThirdGrayColor),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(left: 18.w, right: 18.w, top: 23.h),
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 19.h),
            decoration: BoxDecoration(color: AppColors.appBGColor, borderRadius: BorderRadius.circular(15.dg)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Icon(
                    Icons.notifications_on_sharp,
                  ),
                ),
                Text(
                  'Specialist name',
                  style: appTextStyle16400(AppColors.mainBlackTextColor),
                ),
                Text(
                  'Date',
                  style: appTextStyle16400(AppColors.mainBlackTextColor),
                ),
                Text(
                  'Time',
                  style: appTextStyle16400(AppColors.mainBlackTextColor),
                ),
                Text(
                  'Agreed address of meeting',
                  style: appTextStyle16400(AppColors.mainBlackTextColor),
                ),
                SizedBox(
                  height: 10.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.dg),
                                ),
                                contentPadding: EdgeInsets.zero,
                                title: Column(
                                  children: [
                                    SizedBox(
                                      width: 211.w,
                                      child: Text(
                                        LocaleData.wantToCancelAppointment,
                                        style: appTextStyle16400(AppColors.mainBlackTextColor),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Date',
                                          style: appTextStyle16400(AppColors.mainBlackTextColor),
                                        ),
                                        SizedBox(
                                          width: 4.w,
                                        ),
                                        Text(
                                          'by',
                                          style: appTextStyle16400(AppColors.mainBlackTextColor),
                                        ),
                                        SizedBox(
                                          width: 4.w,
                                        ),
                                        Text(
                                          'Time',
                                          style: appTextStyle16400(AppColors.mainBlackTextColor),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                actions: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                          height: 25.h,
                                          width: 104.w,
                                          child: ReusableButton(
                                              color: AppColors.appBGColor,
                                              text: Text(
                                                LocaleData.no.getString(context),
                                                style: appTextStyle16400(AppColors.mainBlackTextColor),
                                              ),
                                              onPressed: () {})),
                                      SizedBox(
                                          height: 25.h,
                                          width: 104.w,
                                          child: ReusableButton(
                                              color: AppColors.appBGColor,
                                              text: Text(
                                                LocaleData.yes.getString(context),
                                                style: appTextStyle16400(AppColors.mainBlackTextColor),
                                              ),
                                              onPressed: () {})),
                                    ],
                                  ),
                                ],
                              )),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.whiteColor,
                        minimumSize: Size(3.w, 25.h),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: AppColors.newGrayColor, width: 2.w),
                          borderRadius: BorderRadius.circular(5.dg),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          LocaleData.cancel.getString(context),
                          style: appTextStyle12K(AppColors.mainBlackTextColor),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
