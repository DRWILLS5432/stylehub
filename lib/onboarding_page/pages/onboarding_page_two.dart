import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stylehub/constants/app/app_colors.dart';
import 'package:stylehub/constants/app/textstyle.dart';
import 'package:stylehub/constants/localization/locales.dart';

class OnboardingPageTwo extends StatefulWidget {
  const OnboardingPageTwo({super.key});

  @override
  State<OnboardingPageTwo> createState() => _OnboardingPageTwoState();
}

class _OnboardingPageTwoState extends State<OnboardingPageTwo> {
  late String _currentLocale;
  late FlutterLocalization _flutterLocalization;
  List<String> availableLanguages = ['en', 'uk', 'ru'];
  bool _isLanguagePopupVisible = false;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _flutterLocalization = FlutterLocalization.instance;
    _currentLocale = _flutterLocalization.currentLocale?.languageCode ?? 'en';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/GoogleTranslate.png',
            height: 153.h,
            width: 194.w,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 200.w,
            child: Text(
              LocaleData.changeLanguage.getString(context),
              style: bigTextStyle(),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          CompositedTransformTarget(
            link: _layerLink,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isLanguagePopupVisible = !_isLanguagePopupVisible;
                });
              },
              child: Container(
                width: 150.w,
                height: 31.h,
                padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 0),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(50.dg),
                  border: Border.all(color: AppColors.appGrayTextColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      getLanguageName(_currentLocale),
                      style: const TextStyle(color: Colors.black),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Colors.black),
                  ],
                ),
              ),
            ),
          ),
          if (_isLanguagePopupVisible)
            CompositedTransformFollower(
              link: _layerLink,
              offset: Offset(0, 40.h),
              child: Material(
                // Wrap with Material to provide a surface
                color: Colors.transparent,
                child: Container(
                  width: 150.w,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.appGrayTextColor),
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(10.dg),
                  ),
                  child: Column(
                    children: availableLanguages.map((languageCode) {
                      return InkWell(
                        onTap: () {
                          _setLocale(languageCode);
                          setState(() {
                            _isLanguagePopupVisible = false; // Hide popup after selection
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
                          decoration: BoxDecoration(
                            color: _currentLocale == languageCode ? AppColors.appBGColor : Colors.transparent, //Active State
                            borderRadius: BorderRadius.vertical(
                              top: languageCode == availableLanguages.first ? Radius.circular(10.dg) : Radius.zero,
                              bottom: languageCode == availableLanguages.last ? Radius.circular(10.dg) : Radius.zero,
                            ),
                          ),
                          child: Text(
                            getLanguageName(languageCode),
                            style: const TextStyle(color: Colors.black),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
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
