import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:stylehub/constants/app/app_colors.dart';
import 'package:stylehub/constants/app/textstyle.dart';
import 'package:stylehub/constants/localization/locales.dart';
import 'package:stylehub/onboarding_page/onboarding_screen.dart';
import 'package:stylehub/screens/specialist_pages/widgets/write_review.dart';

class SpecialistDetailScreen extends StatefulWidget {
  final String userId;
  const SpecialistDetailScreen({super.key, required this.userId});

  @override
  State<SpecialistDetailScreen> createState() => _SpecialistDetailScreenState();
}

class _SpecialistDetailScreenState extends State<SpecialistDetailScreen> {
  bool toggleReviewField = true;
  bool toggleLikeIcon = false;

  @override
  void initState() {
    super.initState();
    fetchServices();
  }

  void fetchServices() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').doc(widget.userId).collection('services').get();

    print('Manual Fetch - Services count: ${snapshot.docs.length}');
    for (var doc in snapshot.docs) {
      print('Service Data: ${doc.data()}');
    }
  }

  /// Submits a review for a specialist.
  ///
  /// This function checks if the user is logged in and submits a review with the
  /// provided rating and comment for the specified specialist. It adds the review
  /// to the Firestore database under the specialist's user ID. If successful, it
  /// hides the review field and displays a success message. If there's an error
  /// or the user is not logged in, it shows an error message.
  ///
  /// Parameters:
  /// - `rating`: An integer representing the user's rating for the specialist.
  /// - `comment`: A string containing the user's comments or feedback.
  ///
  /// Throws an error message if the user is not logged in or if the review
  /// submission fails.

  // void _submitReview(int rating, String comment) async {
  //   try {
  //     final user = FirebaseAuth.instance.currentUser;
  //     print('Submitting review for user: ${widget.userId}'); // Add this
  //     print('Current auth user: ${user?.uid}'); //
  //     if (user == null) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('You must be logged in')),
  //       );
  //       return;
  //     }

  //     final docRef = await FirebaseFirestore.instance.collection('users').doc(widget.userId).collection('reviews').add({
  //       'rating': rating,
  //       'comment': comment,
  //       'reviewerId': user.uid,
  //       'timestamp': FieldValue.serverTimestamp(),
  //     });
  //     print('Review written with ID: ${docRef.id}');
  //     setState(() => toggleReviewField = false);
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Review submitted successfully!')),
  //     );
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error: ${e.toString()}')),
  //     );
  //   }
  // }

  void _submitReview(int rating, String comment) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication required')),
        );
        return;
      }

      // Get reviewer's name from Firestore
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      String reviewerName = 'Anonymous';
      if (userDoc.exists) {
        reviewerName = userDoc.data()?['firstName'] ?? 'Anonymous';
      }
      // print(reviewerName);
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).collection('reviews').add({
        'rating': rating,
        'comment': comment,
        'reviewerId': user.uid,
        'reviewerName': reviewerName, 
        'timestamp': FieldValue.serverTimestamp(),
      });
      setState(() => toggleReviewField = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 10.w),
              child: InkWell(
                  radius: 10.dg,
                  splashColor: AppColors.whiteColor,
                  highlightColor: AppColors.grayColor,
                  onTap: () {
                    setState(() {
                      toggleLikeIcon = !toggleLikeIcon;
                    });
                  },
                  child: Icon(toggleLikeIcon ? Icons.favorite_border : Icons.favorite, color: AppColors.newThirdGrayColor)),
            )
          ],
        ),
        body: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('services').where('userId', isEqualTo: widget.userId).snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              //  Debug: Print connection state and errors

              final docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                return const Center(child: Text('No service found'));
              }
              final data = docs.first.data();
              final List<dynamic> servicesList = data['services'] ?? [];

              return Stack(
                children: [
                  SingleChildScrollView(
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: double.maxFinite,
                              height: 304.h,
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15.dg), bottomRight: Radius.circular(15.dg)),
                                child: Image.asset(
                                  'assets/master1.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.w),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.location_pin, color: AppColors.newThirdGrayColor),
                                      Text("70m", style: appTextStyle12()),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text('5.0'.toString(), style: appTextStyle15(AppColors.newThirdGrayColor)),
                                      Icon(Icons.star, color: AppColors.mainBlackTextColor, size: 15.dg),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15.w),
                              child: Text(LocaleData.serviceProvide.getString(context), style: appTextStyle15600(AppColors.newThirdGrayColor)),
                            ),
                            SizedBox(height: 20.h),
                            // Padding(
                            //   padding: EdgeInsets.symmetric(horizontal: 21.w),

                            // child: Row(
                            //   children: [
                            //     _buildCategoryIcon('Haircut', 'assets/haircut_icon.png'),
                            //     _buildCategoryIcon('Shave', 'assets/shave_icon.png'),
                            //   ],
                            // ),
                            // ),
                            ...servicesList.map((service) {
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 15.w),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(service['service'] ?? 'No service name'),
                                    Text('--'),
                                    Text('₦${service['price'] ?? '0'}'),
                                  ],
                                ),
                              );
                            }),
                            SizedBox(height: 36.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15.w),
                              child: Text(LocaleData.previousWork.getString(context), style: appTextStyle15600(AppColors.newThirdGrayColor)),
                            ),
                            SizedBox(height: 20.h),
                            SizedBox(
                              height: 196.h,
                              //
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) => Padding(
                                  padding: EdgeInsets.only(left: 15.w),
                                  child: CircleAvatar(
                                    radius: 94.dg,
                                    backgroundColor: AppColors.appBGColor,
                                    child: CircleAvatar(
                                      radius: 90.dg,
                                      backgroundImage: AssetImage(
                                        'assets/master1.png',
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 36.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15.w),
                              child: Text(LocaleData.bio.getString(context), style: appTextStyle15600(AppColors.newThirdGrayColor)),
                            ),
                            SizedBox(height: 10.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15.w),
                              child: Text(data['bio'].toString(), style: appTextStyle15(AppColors.newThirdGrayColor)),
                            ),
                            SizedBox(height: 20.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15.w),
                              child: Row(
                                children: [
                                  Container(
                                      // width: 143.w,
                                      padding: EdgeInsets.symmetric(horizontal: 0.w),
                                      height: 32.h,
                                      child: ReusableButton(
                                        bgColor: AppColors.grayColor,
                                        color: AppColors.appBGColor,
                                        text: Text(LocaleData.callMe.getString(context), style: appTextStyle15600(AppColors.newThirdGrayColor)),
                                        onPressed: () {},
                                      )),
                                ],
                              ),
                            ),
                            SizedBox(height: 36.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15.w),
                              child: Text(LocaleData.reviews.getString(context), style: appTextStyle15600(AppColors.newThirdGrayColor)),
                            ),
                            SizedBox(height: 20.h),
                            InkWell(
                              radius: 20.dg,
                              // onTap: () => setState(() {
                              //   toggleReviewField = !toggleReviewField;
                              // }),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 15.w),
                                child: Row(
                                  children: [
                                    Text(LocaleData.leaveA.getString(context), style: appTextStyle15(AppColors.newThirdGrayColor)),
                                    SizedBox(width: 10.w),
                                    Text(LocaleData.review.getString(context), style: appTextStyle15(AppColors.mainBlackTextColor)),
                                  ],
                                ),
                              ),
                            ),
                            if (toggleReviewField)
                              WriteReviewWidget(
                                toggleReviewField: toggleReviewField,
                                onSubmit: _submitReview,
                              ),

                            SizedBox(
                              height: 18.h,
                            ),
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance.collection('users').doc(widget.userId).collection('reviews').orderBy('timestamp', descending: true).snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                }

                                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                  return Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 15.w),
                                    child: Text(
                                      'No reviews yet',
                                      style: appTextStyle15(AppColors.newThirdGrayColor),
                                    ),
                                  );
                                }

                                final reviews = snapshot.data!.docs;

                                return ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                                  itemCount: reviews.length,
                                  separatorBuilder: (context, index) => SizedBox(height: 16.h),
                                  itemBuilder: (context, index) {
                                    final review = reviews[index].data() as Map<String, dynamic>;
                                    return ReviewCard(review: review);
                                  },
                                );
                              },
                            ),

                            buildProfessionalCard(context, 'Jane Smith', 'Hairstylist', 4.8, onTap: () {}),
                            SizedBox(
                              height: 110.h,
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 100.h,
                      width: double.infinity,
                      color: Colors.grey.withOpacity(0.5),
                      child: Center(
                        child: SizedBox(
                          height: 44.3.h,
                          width: 202.w,
                          child: ReusableButton(
                            bgColor: AppColors.whiteColor,
                            color: AppColors.appBGColor,
                            text: Text('Make Appointment', style: appTextStyle15(AppColors.newThirdGrayColor)),
                            onPressed: () => Navigator.pushNamed(context, '/make_appointment_screen'),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              );
            }));
  }

  Widget _buildCategoryIcon(String label, String assetPath) {
    return InkWell(
      onTap: () {},
      splashColor: AppColors.whiteColor,
      highlightColor: AppColors.grayColor,
      radius: 40.dg,
      // overlayColor: WidgetStateProperty.all(C),
      child: Padding(
        padding: EdgeInsets.only(right: 20.w),
        child: Column(
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(50.dg), child: Image.asset(assetPath, width: 58.17.w, height: 56.91.h)),
            SizedBox(height: 8.h),
            Text(
              label, style: appTextStyle15(AppColors.newThirdGrayColor),
              //  TextStyle(fontSize: 16, fontFamily: 'InstrumentSans'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProfessionalCard(context, String name, String profession, double rating, {Function()? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16.w),
        color: Color(0xFFD7D1BE),
        child: Padding(
          padding: EdgeInsets.only(left: 17.w, right: 17.h, top: 29.h, bottom: 12.h),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(2.dg),
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      borderRadius: BorderRadius.circular(100.dg),
                    ),
                    child: CircleAvatar(
                      radius: 30.dg,
                      backgroundImage: AssetImage('assets/master1.png'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 5.h),
                        Text(name, style: appTextStyle15(AppColors.newThirdGrayColor)),
                        Row(
                          children: List.generate(
                            5,
                            (index) => Icon(
                              index < rating ? Icons.star : Icons.star_border,
                              color: const Color.fromARGB(255, 2, 1, 1),
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
                      SizedBox(width: 250.w, child: Text("Very Good barber and very patient , i recommend", style: appTextStyle15(AppColors.newThirdGrayColor))),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}

class ReviewCard extends StatelessWidget {
  final Map<String, dynamic> review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.dg),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              review['reviewerName'] ?? 'Anonymous',
              style: appTextStyle15600(AppColors.mainBlackTextColor),
            ),
            // Rating Stars
            Row(
              children: List.generate(
                  5,
                  (index) => Icon(
                        index < (review['rating'] as int) ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 20.dg,
                      )),
            ),
            SizedBox(height: 8.h),

            // Comment
            Text(
              review['comment'] ?? '',
              style: appTextStyle15(AppColors.newThirdGrayColor),
            ),
            SizedBox(height: 8.h),

            // Reviewer Info and Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  review['reviewerEmail'] ?? 'Anonymous',
                  style: appTextStyle12(),
                ),
                Text(
                  _formatDate(review['timestamp']?.toDate()),
                  style: appTextStyle12(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('MMM dd, yyyy').format(date);
  }
}
