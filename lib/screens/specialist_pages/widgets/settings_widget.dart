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
    return Container(
      height: 200.h,
      margin: EdgeInsets.only(right: 10.w, left: 10.h, top: 10.h),
      child: Column(
        children: [
          SizedBox(height: 10.h),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.grayColor,
              child: Icon(Icons.person, color: AppColors.mainBlackTextColor),
            ),
            title: Text(
              LocaleData.changePassword.getString(context),
              style: appTextStyle16(AppColors.mainBlackTextColor),
            ),
            subtitle: Text(LocaleData.changePassword.getString(context), style: appTextStyle10(AppColors.mainBlackTextColor)),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: AppColors.mainBlackTextColor,
              size: 16.h,
            ),
          ),
          Divider(color: AppColors.appBGColor),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.grayColor,
              child: Icon(Icons.language, color: AppColors.mainBlackTextColor),
            ),
            title: Text(
              LocaleData.changeLanguage.getString(context),
              style: appTextStyle16(AppColors.mainBlackTextColor),
            ),
            subtitle: Text(LocaleData.changePhoneLanguage.getString(context), style: appTextStyle10(AppColors.mainBlackTextColor)),
            trailing: _buildDropdown(
              value: _currentLocale,
              onChanged: (String? newValue) {
                _setLocale(newValue);
              },
              items: availableLanguages,
            ),
          )
        ],
      ),
    );
  }

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
    width: 80.w,
    height: 28.h,
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 0),
    decoration: BoxDecoration(
      color: AppColors.whiteColor,
      borderRadius: BorderRadius.circular(50.dg),
      border: Border.all(color: AppColors.appBGColor),
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
              style: appTextStyle10(AppColors.mainBlackTextColor),
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
