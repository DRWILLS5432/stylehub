import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stylehub/constants/app/app_colors.dart';
import 'package:stylehub/constants/app/textstyle.dart';
import 'package:stylehub/constants/localization/locales.dart';
import 'package:stylehub/onboarding_page/onboarding_screen.dart';

class SpecialistDetailScreen extends StatefulWidget {
  const SpecialistDetailScreen({super.key});

  @override
  State<SpecialistDetailScreen> createState() => _SpecialistDetailScreenState();
}

class _SpecialistDetailScreenState extends State<SpecialistDetailScreen> {
  bool toggleReviewField = false;
  bool toggleLikeIcon = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10.w),
            child: InkWell(
                radius: 10.dg,
                splashColor: AppColors.whiteColor,
                highlightColor: AppColors.grayColor,
                onTap: () {
                  setState(() {
                    toggleLikeIcon = !toggleLikeIcon;
                  });
                },
                child: Icon(toggleLikeIcon ? Icons.favorite_border : Icons.favorite, color: AppColors.newThirdGrayColor)),
          )
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.maxFinite,
                      height: 304.h,
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15.dg), bottomRight: Radius.circular(15.dg)),
                        child: Image.asset(
                          'assets/master1.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.location_pin, color: AppColors.newThirdGrayColor),
                              Text("70m", style: appTextStyle12()),
                            ],
                          ),
                          Row(
                            children: [
                              Text("5.0", style: appTextStyle15(AppColors.newThirdGrayColor)),
                              Icon(Icons.star, color: AppColors.mainBlackTextColor, size: 15.dg),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15.w),
                      child: Text(LocaleData.serviceProvide.getString(context), style: appTextStyle15600(AppColors.newThirdGrayColor)),
                    ),
                    SizedBox(height: 20.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 21.w),
                      child: Row(
                        children: [
                          _buildCategoryIcon('Haircut', 'assets/haircut_icon.png'),
                          _buildCategoryIcon('Shave', 'assets/shave_icon.png'),
                        ],
                      ),
                    ),
                    SizedBox(height: 36.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15.w),
                      child: Text(LocaleData.previousWork.getString(context), style: appTextStyle15600(AppColors.newThirdGrayColor)),
                    ),
                    SizedBox(height: 20.h),
                    SizedBox(
                      height: 196.h,
                      //
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) => Padding(
                          padding: EdgeInsets.only(left: 15.w),
                          child: CircleAvatar(
                            radius: 94.dg,
                            backgroundColor: AppColors.appBGColor,
                            child: CircleAvatar(
                              radius: 90.dg,
                              backgroundImage: AssetImage(
                                'assets/master1.png',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 36.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15.w),
                      child: Text(LocaleData.bio.getString(context), style: appTextStyle15600(AppColors.newThirdGrayColor)),
                    ),
                    SizedBox(height: 10.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15.w),
                      child: Text('Hello my names jackson villa and i have been a proffessional barber for 100 years now to get more info first call me before making appointment ',
                          style: appTextStyle15(AppColors.newThirdGrayColor)),
                    ),
                    SizedBox(height: 20.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15.w),
                      child: Row(
                        children: [
                          Container(
                              // width: 143.w,
                              padding: EdgeInsets.symmetric(horizontal: 0.w),
                              height: 32.h,
                              child: ReusableButton(
                                bgColor: AppColors.grayColor,
                                color: AppColors.appBGColor,
                                text: Text(LocaleData.callMe.getString(context), style: appTextStyle15600(AppColors.newThirdGrayColor)),
                                onPressed: () {},
                              )),
                        ],
                      ),
                    ),
                    SizedBox(height: 36.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15.w),
                      child: Text(LocaleData.reviews.getString(context), style: appTextStyle15600(AppColors.newThirdGrayColor)),
                    ),
                    SizedBox(height: 20.h),
                    InkWell(
                      radius: 20.dg,
                      onTap: () => setState(() {
                        toggleReviewField = !toggleReviewField;
                      }),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15.w),
                        child: Row(
                          children: [
                            Text(LocaleData.leaveA.getString(context), style: appTextStyle15(AppColors.newThirdGrayColor)),
                            SizedBox(width: 10.w),
                            Text(LocaleData.review.getString(context), style: appTextStyle15(AppColors.mainBlackTextColor)),
                          ],
                        ),
                      ),
                    ),
                    toggleReviewField
                        ? AnimatedOpacity(
                            opacity: toggleReviewField ? 1 : 0,
                            duration: Duration(milliseconds: 900),
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                              // height: toggleReviewField ? 200.h : 0.h,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: AppColors.whiteColor,
                                  borderRadius: BorderRadius.circular(10.dg),
                                  border: Border.all(
                                    color: AppColors.appBGColor,
                                    width: 3.h,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withValues(alpha: 0.5),
                                      spreadRadius: 1,
                                      blurRadius: 2,
                                      offset: Offset(0, 3), // changes position of shadow
                                    ),
                                  ]),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    LocaleData.howDidItGo.getString(context),
                                    style: appTextStyle15600(AppColors.newThirdGrayColor),
                                  ),
                                  SizedBox(
                                    height: 8.h,
                                  ),
                                  Text(
                                    LocaleData.takeAMomentToRate.getString(context),
                                    style: appTextStyle11500(AppColors.newThirdGrayColor),
                                  ),
                                  SizedBox(
                                    height: 20.h,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      5,
                                      (index) => Icon(
                                        index < 5 ? Icons.star : Icons.star_border,
                                        color: const Color.fromARGB(255, 2, 1, 1),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20.h,
                                  ),
                                  TextFormField(
                                    cursorColor: AppColors.newThirdGrayColor,
                                    decoration: InputDecoration(
                                      labelStyle: appTextStyle15(AppColors.newThirdGrayColor),
                                      suffixIcon: Image.asset(
                                        'assets/images/PaperPlane.png',
                                        scale: 0.8,
                                      ),
                                      hintText: LocaleData.writeYourRevHere.getString(context),
                                      hintStyle: appTextStyle15(AppColors.newThirdGrayColor),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10.dg),
                                        borderSide: BorderSide(
                                          color: AppColors.appBGColor,
                                          width: 2.h,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10.dg),
                                        borderSide: BorderSide(
                                          color: AppColors.appBGColor,
                                          width: 2.h,
                                        ),
                                      ),
                                    ),
                                    maxLines: 1,
                                  )
                                ],
                              ),
                            ),
                          )
                        : Container(),
                    SizedBox(
                      height: 18.h,
                    ),
                    buildProfessionalCard(context, 'Jane Smith', 'Hairstylist', 4.8, onTap: () {}),
                    SizedBox(
                      height: 110.h,
                    )
                  ],
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 100.h,
              width: double.infinity,
              color: Colors.grey.withOpacity(0.5),
              child: Center(
                child: SizedBox(
                  height: 44.3.h,
                  width: 202.w,
                  child: ReusableButton(
                    bgColor: AppColors.whiteColor,
                    color: AppColors.appBGColor,
                    text: Text('Make Appointment', style: appTextStyle15(AppColors.newThirdGrayColor)),
                    onPressed: () => Navigator.pushNamed(context, '/make_appointment_screen'),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCategoryIcon(String label, String assetPath) {
    return InkWell(
      onTap: () {},
      splashColor: AppColors.whiteColor,
      highlightColor: AppColors.grayColor,
      radius: 40.dg,
      // overlayColor: WidgetStateProperty.all(C),
      child: Padding(
        padding: EdgeInsets.only(right: 20.w),
        child: Column(
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(50.dg), child: Image.asset(assetPath, width: 58.17.w, height: 56.91.h)),
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
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16.w),
        color: Color(0xFFD7D1BE),
        child: Padding(
          padding: EdgeInsets.only(left: 17.w, right: 17.h, top: 29.h, bottom: 12.h),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(2.dg),
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      borderRadius: BorderRadius.circular(100.dg),
                    ),
                    child: CircleAvatar(
                      radius: 30.dg,
                      backgroundImage: AssetImage('assets/master1.png'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 5.h),
                        Text(name, style: appTextStyle15(AppColors.newThirdGrayColor)),
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
                      SizedBox(width: 250.w, child: Text("Very Good barber and very patient , i recommend", style: appTextStyle15(AppColors.newThirdGrayColor))),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
