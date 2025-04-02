import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:stylehub/constants/app/app_colors.dart';
import 'package:stylehub/constants/app/textstyle.dart';
import 'package:stylehub/onboarding_page/onboarding_screen.dart';
import 'package:stylehub/screens/specialist_pages/provider/filter_provider.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final List<String> cities = ['Petrozavodsk', 'Moscow', 'Saint-Petersburg', 'Omsk'];

  @override
  Widget build(BuildContext context) {
    final filterProvider = Provider.of<FilterProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        actions: [
          if (filterProvider.filtersApplied)
            TextButton(
              onPressed: () {
                filterProvider.clearFilters();
              },
              child: Text(
                'Clear',
                style: appTextStyle16(AppColors.mainBlackTextColor),
              ),
            ),
        ],
      ),
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
                    'Filters',
                    style: appTextStyle24(AppColors.mainBlackTextColor),
                  ),
                  if (filterProvider.filtersApplied)
                    Center(
                      child: SizedBox(
                        // width: 272.w,
                        child: TextButton(
                          onPressed: () {
                            filterProvider.clearFilters();
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Clear Filters',
                            style: appTextStyle16(AppColors.primaryRedColor),
                          ),
                        ),
                      ),
                    ),
                  // Image.asset(
                  //   'assets/categ_settings.png',
                  //   width: 24,
                  //   height: 24,
                  // ),
                ],
              ),
              SizedBox(height: 40.h),
              Text(
                'Proximity',
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
                    value: filterProvider.nearestSpecialists,
                    onChanged: (bool? value) {
                      filterProvider.toggleNearestSpecialists(value ?? false);
                    },
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
                    value: filterProvider.specialistsInCity,
                    onChanged: (bool? value) {
                      filterProvider.toggleSpecialistsInCity(value ?? false);
                    },
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
                    value: filterProvider.highestRating,
                    onChanged: (bool? value) {
                      filterProvider.toggleHighestRating(value ?? false);
                    },
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
                    value: filterProvider.mediumRating,
                    onChanged: (bool? value) {
                      filterProvider.toggleMediumRating(value ?? false);
                    },
                  )
                ],
              ),
              SizedBox(height: 20.h),
              Text(
                'City',
                style: appTextStyle20(AppColors.mainBlackTextColor),
              ),
              SizedBox(height: 20.h),
              DropdownButtonFormField<String>(
                value: filterProvider.selectedCity,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                ),
                hint: Text('Select City'),
                items: cities.map((String city) {
                  return DropdownMenuItem<String>(
                    value: city,
                    child: Text(city),
                  );
                }).toList(),
                onChanged: (String? value) {
                  filterProvider.setSelectedCity(value);
                },
              ),
              Spacer(),
              Column(
                children: [
                  Center(
                    child: SizedBox(
                      width: 272.w,
                      child: ReusableButton(
                        height: 60.h,
                        color: AppColors.appBGColor,
                        bgColor: AppColors.grayColor,
                        text: Text(
                          'Apply Filters',
                          style: appTextStyle16(AppColors.newThirdGrayColor),
                        ),
                        onPressed: () {
                          filterProvider.applyFilters();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
              // SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
