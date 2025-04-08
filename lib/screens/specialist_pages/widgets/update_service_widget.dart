import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:stylehub/constants/app/app_colors.dart';
import 'package:stylehub/constants/app/textstyle.dart';
import 'package:stylehub/constants/localization/locales.dart';
import 'package:stylehub/screens/specialist_pages/provider/edit_category_provider.dart';
import 'package:stylehub/screens/specialist_pages/widgets/edit_category_screen.dart';
import 'package:stylehub/screens/specialist_pages/widgets/personal_detail_screen.dart';
import 'package:stylehub/storage/fire_store_method.dart';

class UpdateServiceWidget extends StatefulWidget {
  const UpdateServiceWidget({super.key});

  @override
  State<UpdateServiceWidget> createState() => _UpdateServiceWidgetState();
}

class _UpdateServiceWidgetState extends State<UpdateServiceWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _professionController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();

  bool isLoading = false;
  bool _isAvailable = false;
  bool _isLoading = false;
  List<File> _imageFiles = [];
  bool _isEditingProfession = false;
  bool _isEditingExperience = false;
  bool _isEditingCity = false;
  bool _isEditingBio = false;
  bool _isEditingPhone = false;
  Map<String, dynamic>? _initialData;

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      setState(() {
        _initialData = doc.data();
        _professionController.text = _initialData?['profession'] ?? '';
        _experienceController.text = _initialData?['experience'] ?? '';
        _cityController.text = _initialData?['city'] ?? '';
        _bioController.text = _initialData?['bio'] ?? '';
        _phoneController.text = _initialData?['phone'] ?? '';
        _isAvailable = _initialData?['isAvailable'] ?? false;
      });
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    setState(() {
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

  Future<void> uploadPreviousWork() async {
    setState(() => isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      List<String> imageUrls = [];
      if (_imageFiles.isNotEmpty) {
        imageUrls = await _uploadImages(user.uid);
      }

      final res = await FireStoreMethod().addImages(userId: user.uid, newImages: imageUrls);

      if (res == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Images updated successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $res')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating images: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateProfession(BuildContext context) async {
    if (_professionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profession cannot be empty')),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final res = await FireStoreMethod().updateServiceProfession(
        userId: user.uid,
        newProfession: _professionController.text,
      );

      if (res == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profession updated successfully!')),
        );
        setState(() {
          _initialData = {
            ...?_initialData,
            'profession': _professionController.text,
          };
          _isEditingProfession = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $res')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profession: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateExperience(BuildContext context) async {
    if (_experienceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Experience field cannot be empty')),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final res = await FireStoreMethod().updateExperience(
        userId: user.uid,
        newExperience: _experienceController.text,
      );

      if (res == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Experience updated successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $res')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating experience: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateCity(BuildContext context) async {
    if (_cityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('City field cannot be empty')),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final res = await FireStoreMethod().updateCity(
        userId: user.uid,
        newCity: _cityController.text,
      );

      if (res == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('City updated successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $res')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating City: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateBio(BuildContext context) async {
    if (_bioController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bio field cannot be empty')),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final res = await FireStoreMethod().updateBio(
        userId: user.uid,
        newBio: _bioController.text,
      );

      if (res == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bio updated successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $res')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating Bio: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _updatePhone(BuildContext context) async {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number field cannot be empty')),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final res = await FireStoreMethod().updatePhone(
        userId: user.uid,
        newPhone: _phoneController.text,
      );

      if (res == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Phone number updated successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $res')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating Phone number: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateAvailability(bool value) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'isAvailable': value,
        'availabilityUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      setState(() {
        _isAvailable = value;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating availability: $e')),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _bioController.dispose();
    _cityController.dispose();
    _experienceController.dispose();
    _phoneController.dispose();
    _professionController.dispose();
    super.dispose();
  }

  Widget _buildProfessionSection() {
    final hasProfession = _initialData?['profession'] != null && _initialData!['profession'].toString().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PersonalDetailText(text: LocaleData.profession.getString(context)),
        SizedBox(height: 15.h),
        TextFormField(
          controller: _professionController,
          decoration: InputDecoration(
            labelStyle: appTextStyle12K(AppColors.appGrayTextColor),
            hintStyle: appTextStyle16400(AppColors.appGrayTextColor),
            hintText: '',
            fillColor: AppColors.grayColor,
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.h), borderSide: BorderSide.none),
          ),
          enabled: _isEditingProfession || !hasProfession,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                if (_isEditingProfession || !hasProfession) {
                  _updateProfession(context);
                }
                setState(() {
                  _isEditingProfession = !_isEditingProfession;
                });
              },
              child: Text(
                _isEditingProfession
                    ? LocaleData.save.getString(context)
                    : hasProfession
                        ? LocaleData.edit.getString(context)
                        : LocaleData.create.getString(context),
                style: appTextStyle14(AppColors.newThirdGrayColor),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExperienceSection() {
    final hasExperience = _initialData?['experience'] != null && _initialData!['experience'].toString().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PersonalDetailText(text: LocaleData.yearsOfExperience.getString(context)),
        SizedBox(height: 15.h),
        TextFormField(
          controller: _experienceController,
          decoration: InputDecoration(
            labelStyle: appTextStyle12K(AppColors.appGrayTextColor),
            hintStyle: appTextStyle16400(AppColors.appGrayTextColor),
            hintText: '',
            fillColor: AppColors.grayColor,
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.h), borderSide: BorderSide.none),
          ),
          enabled: _isEditingExperience || !hasExperience,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                if (_isEditingExperience || !hasExperience) {
                  _updateExperience(context);
                }
                setState(() {
                  _isEditingExperience = !_isEditingExperience;
                });
              },
              child: Text(
                _isEditingExperience
                    ? LocaleData.save.getString(context)
                    : hasExperience
                        ? LocaleData.edit.getString(context)
                        : LocaleData.create.getString(context),
                style: appTextStyle14(AppColors.newThirdGrayColor),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCitySection() {
    final hasCity = _initialData?['city'] != null && _initialData!['city'].toString().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PersonalDetailText(text: LocaleData.city.getString(context)),
        SizedBox(height: 15.h),
        TextFormField(
          controller: _cityController,
          decoration: InputDecoration(
            labelStyle: appTextStyle12K(AppColors.appGrayTextColor),
            hintStyle: appTextStyle16400(AppColors.appGrayTextColor),
            hintText: '',
            fillColor: AppColors.grayColor,
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.h), borderSide: BorderSide.none),
          ),
          enabled: _isEditingCity || !hasCity,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                if (_isEditingCity || !hasCity) {
                  _updateCity(context);
                }
                setState(() {
                  _isEditingCity = !_isEditingCity;
                });
              },
              child: Text(
                _isEditingCity
                    ? LocaleData.save.getString(context)
                    : hasCity
                        ? LocaleData.edit.getString(context)
                        : LocaleData.create.getString(context),
                style: appTextStyle14(AppColors.newThirdGrayColor),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBioSection() {
    final hasBio = _initialData?['bio'] != null && _initialData!['bio'].toString().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PersonalDetailText(text: LocaleData.bio.getString(context)),
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
          enabled: _isEditingBio || !hasBio,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a bio';
            }
            return null;
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                if (_isEditingBio || !hasBio) {
                  _updateBio(context);
                }
                setState(() {
                  _isEditingBio = !_isEditingBio;
                });
              },
              child: Text(
                _isEditingBio
                    ? LocaleData.save.getString(context)
                    : hasBio
                        ? LocaleData.edit.getString(context)
                        : LocaleData.create.getString(context),
                style: appTextStyle14(AppColors.newThirdGrayColor),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhoneSection() {
    final hasPhone = _initialData?['phone'] != null && _initialData!['phone'].toString().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PersonalDetailText(text: LocaleData.phoneNumber.getString(context)),
        SizedBox(height: 15.h),
        TextFormField(
          controller: _phoneController,
          decoration: InputDecoration(
            labelStyle: appTextStyle12K(AppColors.appGrayTextColor),
            hintStyle: appTextStyle16400(AppColors.appGrayTextColor),
            hintText: '',
            fillColor: AppColors.grayColor,
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.h), borderSide: BorderSide.none),
          ),
          enabled: _isEditingPhone || !hasPhone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your phone number';
            }
            return null;
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                if (_isEditingPhone || !hasPhone) {
                  _updatePhone(context);
                }
                setState(() {
                  _isEditingPhone = !_isEditingPhone;
                });
              },
              child: Text(
                _isEditingPhone
                    ? LocaleData.save.getString(context)
                    : hasPhone
                        ? LocaleData.edit.getString(context)
                        : LocaleData.create.getString(context),
                style: appTextStyle14(AppColors.newThirdGrayColor),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EditCategoryProvider>(context);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('User not logged in'));
    }

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
                    Expanded(
                      child: Text(
                        LocaleData.specialistDetails.getString(context),
                        style: appTextStyle205(AppColors.newThirdGrayColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        LocaleData.goToClient.getString(context),
                        style: appTextStyle205(AppColors.newThirdGrayColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Switch(
                      value: _isAvailable,
                      onChanged: _isLoading ? null : _updateAvailability,
                      activeColor: AppColors.greenColor,
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                _buildProfessionSection(),
                SizedBox(height: 24.h),
                _buildExperienceSection(),
                SizedBox(height: 24.h),
                _buildCitySection(),
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: PersonalDetailText(
                        text: LocaleData.serviceCategory.getString(context),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ServiceSelectionScreen())),
                      child: Text(
                        'Edit',
                        style: appTextStyle14(AppColors.newThirdGrayColor),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15.h),
                Wrap(
                  spacing: 8,
                  children: provider.submittedCategories.isNotEmpty
                      ? provider.submittedCategories.map((categoryId) {
                          final categoryName = provider.getCategoryName(categoryId, 'en');
                          return Chip(
                            backgroundColor: AppColors.grayColor,
                            label: Text(
                              categoryName,
                              style: appTextStyle12K(AppColors.mainBlackTextColor),
                            ),
                          );
                        }).toList()
                      : (_initialData?['categories'] as List?)?.map<Widget>((category) {
                            return Chip(
                              backgroundColor: AppColors.grayColor,
                              label: Text(
                                category.toString(),
                                style: appTextStyle12K(AppColors.mainBlackTextColor),
                              ),
                            );
                          }).toList() ??
                          [
                            Text(
                              'No categories selected',
                              style: appTextStyle12K(AppColors.mainBlackTextColor),
                            )
                          ],
                ),
                const SizedBox(height: 24),
                PersonalDetailText(
                  text: LocaleData.services.getString(context),
                ),
                ...(provider.submittedServices.isNotEmpty
                    ? provider.submittedServices.map((service) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  service.name,
                                  style: appTextStyle15(AppColors.mainBlackTextColor),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '-',
                                  style: appTextStyle15(AppColors.mainBlackTextColor),
                                ),
                                Text(
                                  service.price,
                                  style: appTextStyle15(AppColors.mainBlackTextColor),
                                  overflow: TextOverflow.ellipsis,
                                )
                              ],
                            ),
                          ],
                        );
                      }).toList()
                    : (_initialData?['services'] as List?)?.map((service) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      service['service'] ?? '',
                                      style: appTextStyle15(AppColors.mainBlackTextColor),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    '-',
                                    style: appTextStyle15(AppColors.mainBlackTextColor),
                                  ),
                                  Expanded(
                                    child: Text(
                                      service['price'] ?? '',
                                      style: appTextStyle15(AppColors.mainBlackTextColor),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                ],
                              ),
                            ],
                          );
                        }).toList() ??
                        []),
                const SizedBox(height: 40),
                _buildBioSection(),
                SizedBox(height: 24.h),
                _buildPhoneSection(),
                SizedBox(height: 24.h),
                PersonalDetailText(
                  text: LocaleData.previousWork.getString(context),
                ),
                SizedBox(height: 20.h),
                _imageFiles.isNotEmpty
                    ? GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 4.0,
                          mainAxisSpacing: 4.0,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: _imageFiles.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              Text(
                                LocaleData.youCanUploadMore.getString(context),
                                style: appTextStyle12K(AppColors.mainBlackTextColor),
                                textAlign: TextAlign.center,
                              ),
                              Spacer(),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20.h),
                                child: Image.file(
                                  _imageFiles[index],
                                  fit: BoxFit.cover,
                                  width: 150,
                                  height: 150,
                                ),
                              ),
                              Spacer(),
                              TextButton(
                                onPressed: () async {
                                  await uploadPreviousWork();
                                },
                                child: isLoading
                                    ? const CircularProgressIndicator()
                                    : Text(
                                        LocaleData.save.getString(context),
                                        style: appTextStyle14(AppColors.mainBlackTextColor),
                                      ),
                              )
                            ],
                          );
                        },
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: _pickImages,
                            child: CircleAvatar(
                              backgroundColor: AppColors.grayColor,
                              radius: 70.h,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(width: 5.w),
                                  Icon(
                                    Icons.cloud_upload_outlined,
                                    color: AppColors.mainBlackTextColor,
                                  )
                                ],
                              ),
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
                const SizedBox(height: 20),
                const SizedBox(height: 20),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
