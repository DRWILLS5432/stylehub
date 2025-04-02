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
  // List<XFile> _pickedImageFiles = [];
  List<File> _imageFiles = [];

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadInitialAvailability();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    setState(() {
      // _pickedImageFiles = pickedFiles;
      _imageFiles = pickedFiles.map((pickedFile) => File(pickedFile.path)).toList();
    });
  }

  /// Uploads all images in [_imageFiles] to Firebase Storage and returns a list of
  /// URLs that can be used to access the images.
  ///
  /// The images are stored in a directory with the structure 'user-images/$userId/$imageId',
  /// where $userId is the ID of the user making the upload and $imageId is a unique
  /// identifier for the image (a timestamp in milliseconds).
  ///
  /// The function returns a list of URLs that can be used to access the images.
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
    // Upload images
    List<String> imageUrls = [];
    if (_imageFiles.isNotEmpty) {
      imageUrls = await _uploadImages(user.uid);
    }
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

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

  Future<void> _uploadData() async {
    setState(() => isLoading = true);
    final provider = Provider.of<EditCategoryProvider>(context, listen: false);

    if (_formKey.currentState!.validate()) {
      // Validate services and categories
      if (provider.submittedServices.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one service')),
        );
        setState(() => isLoading = false);
        return;
      }

      if (provider.submittedCategories.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one category')),
        );
        setState(() => isLoading = false);
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      try {
        // Upload images
        List<String> imageUrls = [];
        if (_imageFiles.isNotEmpty) {
          imageUrls = await _uploadImages(user.uid);
        }

        // Convert services to List<Map>
        List<Map<String, String>> services = provider.submittedServices
            .map((service) => {
                  'service': service.name,
                  'price': service.price,
                })
            .toList();

        // Upload all data
        final res = await FireStoreMethod().uploadServiceDetails(
          userId: user.uid,
          bio: _bioController.text,
          phone: _phoneController.text,
          city: _cityController.text,
          profession: _professionController.text,
          experience: _experienceController.text,
          services: services,
          categories: provider.submittedCategories,
          images: imageUrls,
        );

        if (res == 'success') {
          // Clear form and state
          _professionController.clear();
          _experienceController.clear();
          _bioController.clear();
          _phoneController.clear();
          _cityController.clear();
          provider.clearSelections();
          setState(() => _imageFiles.clear());

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
    setState(() => isLoading = false);
  }

  /// Updates the specialist's profession in the database.
  ///
  /// If the specialist is not signed in, does nothing.
  ///
  /// If the profession is empty, shows an error snackbar and returns.
  ///
  /// Otherwise, calls `updateServiceProfession` with the new profession and shows a
  /// success or error snackbar depending on the result.
  ///
  /// Sets `isLoading` to true while the request is in progress, then sets it back to false
  /// when complete.
  Future<void> _updateProfession(context) async {
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

  Future<void> _updateExperience(context) async {
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

  Future<void> _updateCity(context) async {
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

  Future<void> _updateBio(context) async {
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

  Future<void> _updatePhone(context) async {
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

  /// Loads the initial availability of the specialist from the database.
  ///
  /// If the specialist is signed in, loads the 'isAvailable' field of their user document
  /// and updates the local state with the value. If the field does not exist, sets the
  /// local state to false. If the specialist is not signed in, does nothing.
  Future<void> _loadInitialAvailability() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      setState(() {
        _isAvailable = doc.data()?['isAvailable'] ?? false;
      });
    }
    return;
  }

  /// Updates the specialist's availability in the database.
  ///
  /// If the specialist is not signed in, does nothing.
  ///
  /// Updates the 'isAvailable' field of the specialist's user document to the given
  /// value, and sets the 'availabilityUpdated' field to the current timestamp.
  ///
  /// Shows a success or error snackbar depending on the result.
  ///
  /// Sets `_isLoading` to true while the request is in progress, then sets it back to false
  /// when complete.
  Future<void> _updateAvailability(bool value) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'isAvailable': value,
        'availabilityUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // Merge with existing document
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating availability: $e')),
      );
    }
    setState(() => _isLoading = false);
  }

  final List<ServiceEntry> _services = [ServiceEntry()];

  // void _addService() {
  //   setState(() {
  //     _services.add(ServiceEntry());
  //   });
  // }

  @override
  void dispose() {
    for (var entry in _services) {
      entry.serviceController.dispose();
      entry.priceController.dispose();
      _bioController.dispose();
      _cityController.dispose();
      _experienceController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EditCategoryProvider>(context);
    final user = FirebaseAuth.instance.currentUser;

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      LocaleData.goToClient.getString(context),
                      style: appTextStyle205(AppColors.newThirdGrayColor),
                    ),
                    StreamBuilder<DocumentSnapshot>(
                      stream: _firestore.collection('users').doc(user!.uid).snapshots(),
                      builder: (context, snapshot) {
                        final isAvailable = snapshot.data?['isAvailable'] ?? false;
                        return Switch(
                          value: isAvailable,
                          onChanged: _isLoading ? null : _updateAvailability,
                          activeColor: AppColors.greenColor,
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 44.h),
                PersonalDetailText(
                  text: LocaleData.profession.getString(context),
                ),
                SizedBox(height: 15.h),
                PersonalDetailForm(controller: _professionController, hintText: ''),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => isLoading ? null : _updateProfession(context),
                      child: Text(
                        'Save',
                        style: appTextStyle14(AppColors.newThirdGrayColor),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                PersonalDetailText(
                  text: LocaleData.yearsOfExperience.getString(context),
                ),
                SizedBox(height: 15.h),
                PersonalDetailForm(controller: _experienceController, hintText: ''),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => isLoading ? null : _updateExperience(context),
                      child: Text(
                        'Save',
                        style: appTextStyle14(AppColors.newThirdGrayColor),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                PersonalDetailText(
                  text: LocaleData.city.getString(context),
                ),
                SizedBox(height: 15.h),
                PersonalDetailForm(controller: _cityController, hintText: ''),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => isLoading ? null : _updateCity(context),
                      child: Text(
                        'Save',
                        style: appTextStyle14(AppColors.newThirdGrayColor),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PersonalDetailText(
                      text: LocaleData.serviceCategory.getString(context),
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
                      ? provider.submittedCategories
                          .map((category) => Chip(
                              backgroundColor: AppColors.grayColor,
                              label: Text(
                                category,
                                style: appTextStyle12K(AppColors.mainBlackTextColor),
                              )))
                          .toList()
                      : [
                          Text(
                            'No categories selected',
                          )
                        ],
                ),
                const SizedBox(height: 24),
                ...provider.submittedServices.asMap().entries.map((entry) {
                  // final index = entry.key;
                  final service = entry.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PersonalDetailText(
                        text: LocaleData.services.getString(context),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            service.name,
                            style: appTextStyle15(AppColors.mainBlackTextColor),
                          ),
                          Text(
                            '-',
                            style: appTextStyle15(AppColors.mainBlackTextColor),
                          ),
                          Text(
                            service.price,
                            style: appTextStyle15(AppColors.mainBlackTextColor),
                          )
                        ],
                      ),
                    ],
                  );
                }),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => isLoading ? null : _updateBio(context),
                      child: Text(
                        'Save',
                        style: appTextStyle14(AppColors.newThirdGrayColor),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                PersonalDetailText(
                  text: LocaleData.phoneNumber.getString(context),
                ),
                SizedBox(height: 15.h),
                PersonalDetailForm(
                  controller: _phoneController,
                  hintText: '',
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
                      onPressed: () => isLoading ? null : _updatePhone(context),
                      child: Text(
                        'Save',
                        style: appTextStyle14(AppColors.newThirdGrayColor),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                PersonalDetailText(
                  text: LocaleData.previousWork.getString(context),
                ),
                SizedBox(height: 20.h),
                _imageFiles.isNotEmpty
                    ? GridView.builder(
                        shrinkWrap: true,
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
                                'You can Upload another photo after saving this one',
                                style: appTextStyle12K(AppColors.mainBlackTextColor),
                                textAlign: TextAlign.center,
                              ),
                              Spacer(),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20.h),
                                child: Image.file(
                                  _imageFiles[index],
                                  fit: BoxFit.cover,
                                  scale: 7,
                                ),
                              ),
                              Spacer(),
                              TextButton(
                                onPressed: () async {
                                  await uploadPreviousWork();
                                },
                                child: isLoading
                                    ? CircularProgressIndicator()
                                    : Text(
                                        'Save Image',
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
                const SizedBox(height: 20),
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
                const SizedBox(height: 20),
                // ElevatedButton(
                //   style: ElevatedButton.styleFrom(
                //     padding: EdgeInsets.zero,
                //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.dg)),
                //     backgroundColor: AppColors.appBGColor,
                //     minimumSize: Size(double.infinity.w, 56.h),
                //   ),
                //   onPressed: () async {
                //     await uploadPreviousWork();
                //   },
                //   child: isLoading ? CircularProgressIndicator() : Text('Submit'),
                // ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ServiceEntry {
  final TextEditingController serviceController;
  final TextEditingController priceController;

  ServiceEntry()
      : serviceController = TextEditingController(),
        priceController = TextEditingController();
}
