import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stylehub/constants/app/app_colors.dart';
import 'package:stylehub/constants/app/textstyle.dart';
import 'package:stylehub/constants/localization/locales.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({super.key});

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  late String _currentLocale;
  late FlutterLocalization _flutterLocalization;
  List<String> availableLanguages = ['en', 'uk', 'ru']; // Correct language codes

  @override
  void initState() {
    super.initState();
    _flutterLocalization = FlutterLocalization.instance;
    _currentLocale = _flutterLocalization.currentLocale?.languageCode ?? 'en'; // Default to 'en'
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
      ),
      body: Container(
        margin: EdgeInsets.only(right: 33.w, left: 33.h, top: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(height: 50.h, width: 50.w, child: Image.asset('assets/images/Settings.png')),
                SizedBox(width: 5.w),
                Text(
                  LocaleData.personalDetails.getString(context),
                  style: appTextStyle205(AppColors.newThirdGrayColor),
                ),
              ],
            ),
            SizedBox(height: 44.h),
            // SizedBox(height: 10.h),
            Text(
              LocaleData.language.getString(context),
              style: appTextStyle15(AppColors.appGrayTextColor),
            ),
            SizedBox(height: 14.h),
            _buildDropdown(
              value: _currentLocale,
              onChanged: (String? newValue) {
                _setLocale(newValue);
              },
              items: availableLanguages,
            ),
            SizedBox(
              height: 45.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  LocaleData.notifications.getString(context),
                  style: appTextStyle12K(AppColors.appGrayTextColor),
                ),
                Switch(
                    activeColor: AppColors.whiteColor,
                    activeTrackColor: AppColors.greenColor,
                    value: isSwitch,
                    onChanged: (value) {
                      setState(() {
                        isSwitch = value;
                      });
                    })
              ],
            )
          ],
        ),
      ),
    );
  }

  bool isSwitch = false;
  void _setLocale(String? value) {
    if (value == null) return;

    String languageCode = value;
    switch (languageCode) {
      case 'en':
        _flutterLocalization.translate('en');
        break;
      case 'ru':
        _flutterLocalization.translate('ru');
        break;
      case 'uk':
        _flutterLocalization.translate('uk');
        break;
      default:
        return;
    }

    setState(() {
      _currentLocale = value;
      Navigator.pop(context);
    });
  }
}

Widget _buildDropdown({
  required String value,
  required ValueChanged<String?> onChanged,
  required List<String> items,
}) {
  return Container(
    // width: 80.w,
    // height: 28.h,
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 0),
    decoration: BoxDecoration(
      color: AppColors.grayColor,
      borderRadius: BorderRadius.circular(10.dg),
      border: Border.all(color: AppColors.mainBlackTextColor),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        borderRadius: BorderRadius.circular(12.dg),

        isExpanded: true, // Added to take available space
        padding: EdgeInsets.zero,
        value: value,
        onChanged: onChanged,
        items: items.map<DropdownMenuItem<String>>((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              getLanguageName(item), // Added to get name for each language code
              style: appTextStyle16400(AppColors.appGrayTextColor),
            ),
          );
        }).toList(),
        dropdownColor: AppColors.whiteColor,
        style: const TextStyle(color: Colors.black),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
      ),
    ),
  );
}

// Helper function to get language name from language code
String getLanguageName(String languageCode) {
  switch (languageCode) {
    case 'en':
      return 'English';
    case 'uk':
      return 'Ukrainian';
    case 'ru':
      return 'Russian';
    default:
      return 'Unknown';
  }
}
