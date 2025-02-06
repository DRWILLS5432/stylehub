import 'package:flutter/material.dart';
import 'package:stylehub/constants/app/app_colors.dart';

class OnboardingPageThree extends StatefulWidget {
  const OnboardingPageThree({super.key});

  @override
  State<OnboardingPageThree> createState() => _OnboardingPageThreeState();
}

class _OnboardingPageThreeState extends State<OnboardingPageThree> {
  final String _selectedCity = 'New York';
  String _selectedCountry = 'New York';
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.location_on,
            size: 100,
            color: AppColors.whiteColor,
          ),
          const SizedBox(height: 20),
          const Text(
            'Select your Country and city',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.whiteColor),
          ),
          const Text(
            'and Turn on Location to show stylists in your city',
            style: TextStyle(fontSize: 18, color: AppColors.whiteColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          // _buildDropdown(
          //   value: _selectedCountry,
          //   onChanged: (String? newValue) {
          //     if (newValue != null) {
          //       setState(() {
          //         _selectedCountry = newValue;
          //       });
          //     }
          //   },
          //   items: const <String>['USA', 'Canada', 'UK'],
          // ),
          const SizedBox(height: 20),
          // _buildDropdown(
          //   value: _selectedCity,
          //   onChanged: (String? newValue) {
          //     if (newValue != null) {
          //       setState(() {
          //         _selectedCity = newValue;
          //       });
          //     }
          //   },
          //   items: const <String>['New York', 'Los Angeles', 'London'],
          // ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required ValueChanged<String?> onChanged,
    required List<String> items,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
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
