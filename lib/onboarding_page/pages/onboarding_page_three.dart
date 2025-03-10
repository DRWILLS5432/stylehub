import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:stylehub/constants/app/app_colors.dart';
import 'package:stylehub/constants/app/textstyle.dart';
import 'package:stylehub/constants/localization/locales.dart';

class OnboardingPageThree extends StatefulWidget {
  const OnboardingPageThree({super.key});

  @override
  State<OnboardingPageThree> createState() => _OnboardingPageThreeState();
}

class _OnboardingPageThreeState extends State<OnboardingPageThree> {
  String? _selectedCountry;
  String? _selectedCity;
  Position? _userPosition;
  bool _isLoading = false;

  final Map<String, List<String>> _countryCities = {
    'Russia': ['Moscow', 'Saint Petersburg', 'Novosibirsk'],
    'Ukraine': ['Kyiv', 'Kharkiv', 'Odessa'],
    'Kazakhstan': ['Nur-Sultan', 'Almaty', 'Shymkent'],
  };

  Future<void> _getUserLocation() async {
    setState(() {
      _isLoading = true;
    });

    // Check location permissions
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled.')),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permissions are permanently denied.')),
      );
      return;
    }

    // Fetch the user's location
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _userPosition = position;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBGColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/Address.png',
                height: 153.h,
                width: 194.w,
              ),
              const SizedBox(height: 20),
              Text(
                LocaleData.yourAddress.getString(context),
                style: bigTextStyle(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              // const Text(
              //   'Turn on Location to show stylists in your city',
              //   style: TextStyle(fontSize: 18, color: AppColors.whiteColor),
              //   textAlign: TextAlign.center,
              // ),
              // const SizedBox(height: 20),
              // _buildDropdown(
              //   value: _selectedCountry,
              //   hint: 'Select Country',
              //   onChanged: (String? newValue) {
              //     setState(() {
              //       _selectedCountry = newValue;
              //       _selectedCity = null; // Reset city when country changes
              //     });
              //   },
              //   items: _countryCities.keys.toList(),
              // ),
              // const SizedBox(height: 20),
              // _buildDropdown(
              //   value: _selectedCity,
              //   hint: 'Select City',
              //   onChanged: (String? newValue) {
              //     setState(() {
              //       _selectedCity = newValue;
              //     });
              //   },
              //   items: _selectedCountry != null ? _countryCities[_selectedCountry]! : [],
              // ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _getUserLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.whiteColor,
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 0),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: AppColors.mainBlackTextColor),
                          borderRadius: BorderRadius.circular(50.dg),
                        ),
                      ),
                      child: Text(
                        'Get my Location',
                        style: appTextStyle14(AppColors.mainBlackTextColor),
                      ),
                    ),
              const SizedBox(height: 20),
              if (_userPosition != null)
                Text(
                  'Your Location: ${_userPosition!.latitude}, ${_userPosition!.longitude}',
                  style: const TextStyle(color: AppColors.whiteColor),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required ValueChanged<String?> onChanged,
    required List<String> items,
  }) {
    return Container(
      height: 40.h,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint),
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
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
}
