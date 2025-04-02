import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:stylehub/constants/app/app_colors.dart';
import 'package:stylehub/constants/app/textstyle.dart';
import 'package:stylehub/constants/localization/locales.dart';
import 'package:stylehub/screens/specialist_pages/model/specialist_model.dart';
import 'package:stylehub/screens/specialist_pages/provider/edit_category_provider.dart';
import 'package:stylehub/screens/specialist_pages/provider/filter_provider.dart';
import 'package:stylehub/screens/specialist_pages/provider/language_provider.dart';
import 'package:stylehub/screens/specialist_pages/specialist_detail_screen.dart';
import 'package:stylehub/storage/fire_store_method.dart';

class SpecialistDashboard extends StatefulWidget {
  const SpecialistDashboard({super.key});

  @override
  State<SpecialistDashboard> createState() => _SpecialistDashboardState();
}

class _SpecialistDashboardState extends State<SpecialistDashboard> {
  String? userName;
  Uint8List? _imageBytes;
  String? currentUserId;
  String? _selectedCategory; // Track selected category

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    fetchCategories();
  }

  void fetchCategories() {
    final provider = Provider.of<EditCategoryProvider>(context, listen: false);
    provider.loadCategories();
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() => currentUserId = user.uid);

      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

        if (userData != null) {
          setState(() {
            userName = userData['firstName'] as String?;
            String? base64Image = userData['profileImage'] as String?;
            if (base64Image != null) {
              try {
                _imageBytes = base64Decode(base64Image);
              } catch (e) {
                // Handle error
              }
            }
          });
        }
      }
    }
  }

  List<String> categoryImages = [
    'assets/images/four.png',
    'assets/images/three.png',
    'assets/images/two.png',
    'assets/images/one.png',
    'assets/images/four.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: CustomScrollView(
        slivers: [
          // First SliverAppBar for the header section
          SliverAppBar(
            expandedHeight: 170.h,
            toolbarHeight: 10.h,
            pinned: true,
            backgroundColor: AppColors.appBGColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12.0),
                    bottomRight: Radius.circular(12.0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile avatar
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/specialist_profile'),
                      child: Hero(
                        tag: '1',
                        child: Container(
                          padding: EdgeInsets.all(4.dg),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100.dg),
                            color: AppColors.appBGColor,
                          ),
                          child: CircleAvatar(
                            radius: 50.dg,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: _imageBytes != null ? MemoryImage(_imageBytes!) : null,
                            child: _imageBytes == null ? Icon(Icons.add_a_photo, size: 30, color: Colors.grey[600]) : null,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                    // Welcome text
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 0.h),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                LocaleData.welcomeBack.getString(context),
                                style: appTextStyle20(AppColors.newGrayColor),
                              ),
                              Text(
                                userName ?? '',
                                style: appTextStyle20(AppColors.newGrayColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Notification icon
                    Padding(
                      padding: EdgeInsets.only(bottom: 30.h),
                      child: Image.asset(
                        'assets/images/Bell.png',
                        height: 26.h,
                        width: 27.w,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Second SliverAppBar for the categories (pinned)
          SliverAppBar(
            floating: true,
            pinned: true,
            toolbarHeight: 130.h,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                height: 120.h,
                color: Color(0xFFD7D1BE),
                padding: EdgeInsets.only(left: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10.h),
                    Text(
                      LocaleData.category.getString(context),
                      style: appTextStyle18(AppColors.newThirdGrayColor),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      height: 110.h,
                      child: Consumer<EditCategoryProvider>(
                        builder: (context, categoryProvider, _) {
                          return Consumer<FilterProvider>(
                            builder: (context, filterProvider, _) {
                              return ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: categoryProvider.availableCategories.length,
                                itemBuilder: (context, index) {
                                  if (categoryProvider.availableCategories.isEmpty) {
                                    return const Center(child: CircularProgressIndicator());
                                  }
                                  final category = categoryProvider.availableCategories[index];
                                  return GestureDetector(
                                    onTap: () {
                                      filterProvider.setSelectedCategory(filterProvider.selectedCategory == category.name ? null : category.name);
                                      filterProvider.applyFilters();
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.only(right: 10.w),
                                      child: Column(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: filterProvider.selectedCategory == category.name ? AppColors.newThirdGrayColor : Colors.transparent,
                                                width: 3,
                                              ),
                                            ),
                                            child: CircleAvatar(
                                              backgroundColor: AppColors.whiteColor,
                                              radius: 35,
                                              backgroundImage: AssetImage(
                                                categoryImages[index % categoryImages.length],
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Consumer<LanguageProvider>(builder: (context, provider, child) {
                                            return Text(
                                              provider.currentLanguage == 'en' ? category.name : category.ruName,
                                              style: appTextStyle15(
                                                filterProvider.selectedCategory == category.name ? Colors.white : AppColors.newThirdGrayColor,
                                              ),
                                            );
                                          }),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Title and filter button
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.h, top: 10.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.dg),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 205.w,
                    child: Text(
                      LocaleData.findProfessional.getString(context),
                      style: appTextStyle16400(AppColors.newThirdGrayColor),
                      overflow: TextOverflow.visible,
                      softWrap: true,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/filter_screen'),
                    child: Image.asset(
                      'assets/categ_settings.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main content with specialists
          StreamBuilder<QuerySnapshot>(
            stream: _getSpecialistsStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Center(child: Text('Error: ${snapshot.error}')),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverToBoxAdapter(
                  child: const Center(child: CircularProgressIndicator()),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Text(
                      'No specialists found',
                      style: appTextStyle16400(AppColors.newThirdGrayColor),
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    SpecialistModel user = SpecialistModel.fromSnap(snapshot.data!.docs[index]);
                    return FutureBuilder<double>(
                      future: FireStoreMethod().getAverageRating(user.userId),
                      builder: (context, ratingSnapshot) {
                        if (ratingSnapshot.connectionState == ConnectionState.waiting) {
                          return SizedBox.shrink();
                        }
                        if (ratingSnapshot.hasError) {
                          return Text("Error loading rating");
                        }

                        double averageRating = ratingSnapshot.data ?? 0.0;
                        return buildProfessionalCard(context, user, averageRating);
                      },
                    );
                  },
                  childCount: snapshot.data!.docs.length,
                ),
              );
            },
          ),

          SliverAppBar(
            toolbarHeight: 40,
          )
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _getSpecialistsStream() {
    final filterProvider = Provider.of<FilterProvider>(context, listen: false);

    Query query = FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'Stylist');

    if (filterProvider.filtersApplied) {
      if (filterProvider.selectedCity != null) {
        query = query.where('city', isEqualTo: filterProvider.selectedCity);
      }

      if (filterProvider.selectedCategory != null) {
        query = query.where('categories', arrayContains: filterProvider.selectedCategory);
      }

      if (filterProvider.highestRating) {
        query = query.orderBy('averageRating', descending: true);
      } else if (filterProvider.mediumRating) {
        query = query.where('averageRating', isGreaterThanOrEqualTo: 2.5).where('averageRating', isLessThan: 4.0);
      }
    }

    return query.snapshots();
  }

  Widget buildProfessionalCard(
    BuildContext context,
    SpecialistModel user,
    double averageRating,
  ) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      color: Color(0xFFD7D1BE),
      child: Padding(
        padding: EdgeInsets.only(left: 17.w, right: 17.h, top: 29.h, bottom: 12.h),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.dg),
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(100.dg),
                  ),
                  child: CircleAvatar(
                    radius: 60.dg,
                    backgroundImage: AssetImage('assets/master1.png'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(user.fullName, style: appTextStyle20(AppColors.newThirdGrayColor)),
                      Text(
                        user.role,
                        style: appTextStyle15(AppColors.newThirdGrayColor),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: List.generate(
                          5,
                          (index) => Icon(
                            index < averageRating ? Icons.star : Icons.star_border,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_pin, color: AppColors.newThirdGrayColor),
                    Text("70m", style: appTextStyle15(AppColors.newThirdGrayColor)),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SpecialistDetailScreen(
                          userId: user.userId,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    LocaleData.view.getString(context),
                    style: appTextStyle14(AppColors.newThirdGrayColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
