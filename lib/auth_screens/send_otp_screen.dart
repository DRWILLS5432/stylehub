import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stylehub/auth_screens/login_page.dart';
import 'package:stylehub/constants/app/app_colors.dart';
import 'package:stylehub/constants/app/textstyle.dart';
import 'package:stylehub/constants/localization/locales.dart';
import 'package:stylehub/onboarding_page/onboarding_screen.dart';
import 'package:stylehub/services/firebase_auth.dart';

class SendOtpScreen extends StatefulWidget {
  const SendOtpScreen({super.key});

  @override
  State<SendOtpScreen> createState() => _SendOtpScreenState();
}

class _SendOtpScreenState extends State<SendOtpScreen> {
  final _emailController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isResendEnabled = false;
  int _remainingSeconds = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    setState(() {
      _isResendEnabled = false;
      _remainingSeconds = 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isResendEnabled = true;
        });
      }
    });
  }

  Future<void> _sendOtp() async {
    setState(() => _isLoading = true);
    try {
      await _firebaseService.sendPasswordResetEmail(_emailController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent! Check your inbox.')),
      );
      startTimer();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  TextSpan _buildResendCodeTextSpan(BuildContext context, bool isResendEnabled, int remainingSeconds) {
    return TextSpan(
      style: appTextStyle16(
        isResendEnabled ? AppColors.mainBlackTextColor : AppColors.appGrayTextColor,
      ),
      children: [
        if (!isResendEnabled)
          TextSpan(
            text: ' $remainingSeconds s',
            style: appTextStyle12K(AppColors.appGrayTextColor),
          ),
        isResendEnabled
            ? TextSpan(text: LocaleData.resendCode.getString(context), style: appTextStyle16700(AppColors.mainBlackTextColor))
            : TextSpan(text: ' ${LocaleData.resendCode.getString(context)}', style: appTextStyle16400(AppColors.mainBlackTextColor)),
        TextSpan(text: ' once timer ends', style: appTextStyle12K(AppColors.mainBlackTextColor)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBGColor,
      appBar: AppBar(
        backgroundColor: AppColors.appBGColor,
        title: SizedBox(
          height: 100.h,
          child: Image.asset(
            'assets/logo.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          // Added SingleChildScrollView
          child: Padding(
            padding: EdgeInsets.all(16.dg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 10.h),
                Text(
                  LocaleData.forgotPassword.getString(context),
                  style: appTextStyle23(AppColors.mainBlackTextColor),
                ),
                SizedBox(height: 60.h),
                Row(
                  children: [
                    Text(
                      LocaleData.enterRegisteredEmail.getString(context),
                      style: appTextStyle15(AppColors.mainBlackTextColor),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelStyle: appTextStyle12K(AppColors.appGrayTextColor),
                    hintStyle: appTextStyle12K(AppColors.appGrayTextColor),
                    hintText: LocaleData.email.getString(context),
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return LocaleData.emailRequired.getString(context);
                    }
                    if (!validateEmail(value)) {
                      return LocaleData.emailInvalid.getString(context);
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.h),
                TextButton(
                  onPressed: _isResendEnabled
                      ? () {
                          if (_formKey.currentState!.validate()) {
                            _sendOtp();
                          }
                        }
                      : null,
                  child: RichText(
                    text: _buildResendCodeTextSpan(context, _isResendEnabled, _remainingSeconds),
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  LocaleData.checkEmail.getString(context),
                  style: appTextStyle14(AppColors.mainBlackTextColor),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 180.h,
                ),
                ReusableButton(
                  text: _isLoading
                      ? SizedBox(
                          height: 20.h,
                          width: 20.w,
                          child: CircularProgressIndicator(
                            color: AppColors.appGrayTextColor,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(LocaleData.sendOTP.getString(context), style: mediumTextStyle25(AppColors.mainBlackTextColor)),
                  // text: LocaleData.register.getString(context),
                  color: Colors.black,
                  bgColor: AppColors.whiteColor,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (!_isLoading) {
                        _sendOtp();
                      }
                    }
                  },
                ),
                // ElevatedButton(
                //   onPressed: () {
                //     if (_formKey.currentState!.validate()) {
                //       if (!_isLoading) {
                //         _sendOtp();
                //       }
                //     }
                //   },
                //   style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(50.h), backgroundColor: Colors.black),
                //   child: _isLoading
                //       ? SizedBox(
                //           height: 20.h,
                //           width: 20.w,
                //           child: const CircularProgressIndicator(
                //             color: Colors.white,
                //             strokeWidth: 2,
                //           ),
                //         )
                //       : Text(LocaleData.sendOTP.getString(context), style: appTextStyle19(AppColors.whiteColor)),
                // ),
                SizedBox(height: 60.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
