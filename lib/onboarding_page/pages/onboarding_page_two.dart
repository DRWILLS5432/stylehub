import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stylehub/constants/app/app_colors.dart';
import 'package:stylehub/constants/localization/locales.dart';

class OnboardingPageTwo extends StatefulWidget {
  const OnboardingPageTwo({super.key});

  @override
  State<OnboardingPageTwo> createState() => _OnboardingPageTwoState();
}

class _OnboardingPageTwoState extends State<OnboardingPageTwo> {
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.language,
            size: 100,
            color: AppColors.whiteColor,
          ),
          const SizedBox(height: 20),
          Text(
            LocaleData.changeLanguage.getString(context), // Use LocaleData
            style: TextStyle(fontSize: 19.sp, color: AppColors.appGrayTextColor),
          ),
          const SizedBox(height: 20),
          _buildDropdown(
            value: _currentLocale,
            onChanged: (String? newValue) {
              _setLocale(newValue);
            },
            items: availableLanguages,
          ),
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
    });
  }

  Widget _buildDropdown({
    required String value,
    required ValueChanged<String?> onChanged,
    required List<String> items,
  }) {
    return Container(
      width: 150.w,
      height: 40.h,
      padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 0),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(50.dg),
        border: Border.all(color: AppColors.appGrayTextColor),
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
                style: const TextStyle(color: Colors.black),
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
}
