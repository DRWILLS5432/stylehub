import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stylehub/constants/app/app_colors.dart';
import 'package:stylehub/constants/app/textstyle.dart';
import 'package:stylehub/constants/localization/locales.dart';
import 'package:stylehub/screens/specialist_pages/widgets/personal_detail_screen.dart';

class UpdateServiceWidget extends StatefulWidget {
  const UpdateServiceWidget({super.key});

  @override
  State<UpdateServiceWidget> createState() => _UpdateServiceWidgetState();
}

class _UpdateServiceWidgetState extends State<UpdateServiceWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _servicesController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  List<XFile> _pickedImageFiles = [];
  List<File> _imageFiles = [];

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    setState(() {
      _pickedImageFiles = pickedFiles;
      _imageFiles = pickedFiles.map((pickedFile) => File(pickedFile.path)).toList();
    });
  }

  Future<List<String>> _uploadImages(String userId) async {
    List<String> imageUrls = [];

    for (var imageFile in _imageFiles) {
      final String imageId = DateTime.now().millisecondsSinceEpoch.toString();
      final Reference storageRef = _storage.ref().child('user-images/$userId/$imageId');
      await storageRef.putFile(imageFile);
      final String imageUrl = await storageRef.getDownloadURL();
      imageUrls.add(imageUrl);
    }

    return imageUrls;
  }

  Future<void> _uploadData() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to update services.')),
        );
        return;
      }

      try {
        // Upload images to Firebase Storage
        final List<String> imageUrls = await _uploadImages(user.uid);

        // Upload data to Firestore
        await _firestore.collection('services').add({
          'userId': user.uid,
          'services': _servicesController.text,
          'bio': _bioController.text,
          'phone': _phoneController.text,
          'images': imageUrls,
          'createdAt': Timestamp.now(),
        });

        print('Data uploaded to Firestore successfully.');

        // Clear form and image data
        _servicesController.clear();
        _bioController.clear();
        _phoneController.clear();
        setState(() {
          _imageFiles.clear();
          _pickedImageFiles.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Services updated successfully!')),
        );
      } catch (e, stackTrace) {
        print('Error: $e');
        print('Stack trace: $stackTrace');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update services: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(height: 50.h, width: 50.w, child: Image.asset('assets/images/Scissors.png')),
                    SizedBox(width: 5.w),
                    Text(
                      LocaleData.specialistDetails.getString(context),
                      style: appTextStyle205(AppColors.newThirdGrayColor),
                    ),
                  ],
                ),
                SizedBox(height: 44.h),
                PersonalDetailText(
                  text: LocaleData.profession.getString(context),
                ),
                SizedBox(height: 15.h),
                PersonalDetailForm(controller: _servicesController, hintText: ''),
                SizedBox(height: 44.h),
                PersonalDetailText(
                  text: LocaleData.yearsOfExperience.getString(context),
                ),
                SizedBox(height: 15.h),
                PersonalDetailForm(controller: _servicesController, hintText: ''),
                SizedBox(height: 44.h),
                PersonalDetailText(
                  text: LocaleData.serviceCategory.getString(context),
                ),
                SizedBox(height: 15.h),
                Row(
                  children: [
                    serviceCategories(),
                    SizedBox(width: 21.w),
                    serviceCategories(),
                  ],
                ),
                const SizedBox(height: 40),
                PersonalDetailText(
                  text: LocaleData.bio.getString(context),
                ),
                SizedBox(height: 15.h),
                TextFormField(
                  controller: _bioController,
                  decoration: InputDecoration(
                    labelStyle: appTextStyle12K(AppColors.appGrayTextColor),
                    hintStyle: appTextStyle16400(AppColors.appGrayTextColor),
                    hintText: '',
                    fillColor: AppColors.grayColor,
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.h), borderSide: BorderSide.none),
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a bio';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 44.h),
                PersonalDetailText(
                  text: LocaleData.phoneNumber.getString(context),
                ),
                SizedBox(height: 15.h),
                PersonalDetailForm(
                  controller: _servicesController,
                  hintText: '',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 44.h),
                PersonalDetailText(
                  text: LocaleData.previousWork.getString(context),
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.grayColor,
                      radius: 70.h,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            LocaleData.uploadImages.getString(context),
                            style: appTextStyle12K(AppColors.mainBlackTextColor),
                          ),
                          SizedBox(
                            width: 5.w,
                          ),
                          Icon(
                            Icons.cloud_upload_outlined,
                            color: AppColors.mainBlackTextColor,
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                        width: 180.w,
                        child: Text(
                          LocaleData.note.getString(context),
                          style: appTextStyle12K(AppColors.mainBlackTextColor),
                        ))
                  ],
                ),
                // ElevatedButton(
                //   onPressed: _pickImages,
                //   child: const Text('Upload Images'),
                // ),
                const SizedBox(height: 80),
                // _imageFiles.isNotEmpty
                //     ? GridView.builder(
                //         shrinkWrap: true,
                //         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                //           crossAxisCount: 3,
                //           crossAxisSpacing: 4.0,
                //           mainAxisSpacing: 4.0,
                //         ),
                //         itemCount: _imageFiles.length,
                //         itemBuilder: (context, index) {
                //           return Image.file(
                //             _imageFiles[index],
                //             fit: BoxFit.cover,
                //           );
                //         },
                //       )
                //     : Container(),
                // const SizedBox(height: 20),
                // ElevatedButton(
                //   onPressed: _uploadData,
                //   child: const Text('Submit'),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container serviceCategories() {
    return Container(
        height: 36.h,
        width: 106.w,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.dg), color: AppColors.grayColor),
        child: Center(
          child: Text(
            'Haircut',
            style: appTextStyle15(AppColors.newThirdGrayColor),
          ),
        ));
  }
}
