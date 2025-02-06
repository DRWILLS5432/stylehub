import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stylehub/constants/app/app_colors.dart';
import 'package:stylehub/constants/localization/locales.dart';
import 'package:stylehub/constants/textstyle.dart';
import 'package:stylehub/services/firebase_auth.dart';

import 'customer_page.dart';
import 'specialist_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? selectedRole;
  final FirebaseService _firebaseService = FirebaseService(); // Create an instance of FirebaseService

  // Loading states
  bool _isRegistering = false;
  bool _isLoggingIn = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBGColor,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.h),
            child: Column(
              children: [
                // SizedBox(height: 20.h),
                SizedBox(
                  height: 120.h,
                  child: Image.asset(
                    'assets/logo.png',
                    // width: 250.h,
                    fit: BoxFit.cover,
                  ),
                ),
                //  SizedBox(height: 20.h),
                TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.black,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  tabs: [
                    Tab(text: LocaleData.createAccount.getString(context)),
                    Tab(text: LocaleData.login.getString(context)),
                  ],
                ),
                SizedBox(height: 40.h),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCreateAccountTab(),
                      _buildLoginTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreateAccountTab() {
    final TextEditingController firstNameController = TextEditingController();
    final TextEditingController lastNameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    Future<void> register() async {
      if (selectedRole == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a role')),
        );
        return;
      }

      setState(() {
        _isRegistering = true; // Start loading
      });

      try {
        User? user = await _firebaseService.registerUser(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          role: selectedRole!,
        );

        if (user != null) {
          if (selectedRole == 'Customer') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => CustomerPage()),
            );
          } else if (selectedRole == 'Stylist') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SpecialistPage()),
            );
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      } finally {
        setState(() {
          _isRegistering = false; // Stop loading
        });
      }
    }

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButtonFormField<String>(
              borderRadius: BorderRadius.circular(14.dg),
              value: selectedRole,
              hint: Text(LocaleData.selectRole.getString(context), style: appTextStyle12K(AppColors.appGrayTextColor)),
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.dg), borderSide: BorderSide.none),
                contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 15.h),
              ),
              onChanged: (String? newValue) {
                setState(() {
                  selectedRole = newValue;
                });
              },
              items: <String>[
                LocaleData.customer.getString(context),
                LocaleData.stylist.getString(context),
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              isExpanded: true,
              style: const TextStyle(color: Colors.black),
              dropdownColor: Colors.white,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
            ),
            SizedBox(height: 20.h),
            TextFormField(
              controller: firstNameController,
              decoration: InputDecoration(
                labelText: LocaleData.firstName.getString(context),
                labelStyle: appTextStyle12K(AppColors.appGrayTextColor),
                hintStyle: appTextStyle12K(AppColors.appGrayTextColor),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.dg), borderSide: BorderSide.none),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return LocaleData.firstNameRequired.getString(context);
                }
                return null;
              },
            ),
            SizedBox(height: 20.h),
            TextFormField(
              controller: lastNameController,
              decoration: InputDecoration(
                labelStyle: appTextStyle12K(AppColors.appGrayTextColor),
                hintStyle: appTextStyle12K(AppColors.appGrayTextColor),
                labelText: LocaleData.lastName.getString(context),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.dg), borderSide: BorderSide.none),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return LocaleData.lastNameRequired.getString(context);
                }
                return null;
              },
            ),
            SizedBox(height: 20.h),
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                labelStyle: appTextStyle12K(AppColors.appGrayTextColor),
                hintStyle: appTextStyle12K(AppColors.appGrayTextColor),
                labelText: LocaleData.email.getString(context),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.h), borderSide: BorderSide.none),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return LocaleData.emailRequired.getString(context);
                }
                if (!validateEmail(value)) {
                  // Use one of the validation methods above
                  return LocaleData.emailInvalid.getString(context);
                }
                return null;
              },
            ),
            SizedBox(height: 20.h),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelStyle: appTextStyle12K(AppColors.appGrayTextColor),
                hintStyle: appTextStyle12K(AppColors.appGrayTextColor),
                labelText: LocaleData.password.getString(context),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.dg), borderSide: BorderSide.none),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return LocaleData.passwordRequired.getString(context);
                } else if (value.length < 6) {
                  return LocaleData.passwordInvalid.getString(context);
                }
                return null;
              },
            ),
            SizedBox(height: 40.h),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  if (selectedRole != null) {
                    // Form is valid AND a role is selected
                    if (!_isRegistering) {
                      // Check if not already registering
                      register(); // Call the register function
                    }
                  } else {
                    // Form is valid BUT NO role is selected
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(LocaleData.roleRequired.getString(context))),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(50.h), backgroundColor: Colors.black),
              child: _isRegistering
                  ? SizedBox(
                      height: 20.h,
                      width: 20.w,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(LocaleData.register.getString(context), style: appTextStyle19(AppColors.whiteColor)),
            ),
            const SizedBox(height: 20),
            Text(LocaleData.termsAndConditions.getString(context), style: appTextStyle12K(AppColors.appGrayTextColor)),
            Text('StyleHub 2024', style: appTextStyle12K(AppColors.appGrayTextColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginTab() {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    Future<void> login() async {
      setState(() {
        _isLoggingIn = true; // Start loading
      });

      try {
        User? user = await _firebaseService.loginUser(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        if (user != null) {
          String? role = await _firebaseService.getUserRole(user.uid);
          if (role == 'Customer') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => CustomerPage()),
            );
          } else if (role == 'Stylist') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SpecialistPage()),
            );
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      } finally {
        setState(() {
          _isLoggingIn = false; // Stop loading
        });
      }
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(LocaleData.welcomeBack.getString(context), style: appTextStyle23(AppColors.mainBlackTextColor)),
          SizedBox(height: 40.h),
          TextFormField(
            controller: emailController,
            decoration: InputDecoration(
              labelStyle: appTextStyle12K(AppColors.appGrayTextColor),
              hintStyle: appTextStyle12K(AppColors.appGrayTextColor),
              labelText: LocaleData.email.getString(context),
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return LocaleData.emailRequired.getString(context);
              }
              if (!validateEmail(value)) {
                // Use one of the validation methods above
                return LocaleData.emailInvalid.getString(context);
              }
              return null;
            },
          ),
          SizedBox(height: 20.h),
          TextFormField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelStyle: appTextStyle12K(AppColors.appGrayTextColor),
              hintStyle: appTextStyle12K(AppColors.appGrayTextColor),
              labelText: LocaleData.password.getString(context),
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return LocaleData.passwordRequired.getString(context);
              }
              return null;
            },
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _isLoggingIn ? null : login();
              }
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50), backgroundColor: Colors.black),
            child: _isLoggingIn
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(LocaleData.login.getString(context), style: appTextStyle19(AppColors.whiteColor)),
          ),
        ],
      ),
    );
  }
}

bool validateEmail(String email) {
  String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';
  RegExp regex = RegExp(pattern);
  return regex.hasMatch(email);
}
