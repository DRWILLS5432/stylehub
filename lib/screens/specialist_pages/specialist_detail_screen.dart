import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:stylehub/constants/app/app_colors.dart';
import 'package:stylehub/constants/app/textstyle.dart';
import 'package:stylehub/constants/localization/locales.dart';
import 'package:stylehub/onboarding_page/onboarding_screen.dart';
import 'package:stylehub/screens/specialist_pages/make_appointment_screen.dart';
import 'package:stylehub/screens/specialist_pages/widgets/write_review.dart';
import 'package:stylehub/storage/post_review_method.dart';

class SpecialistDetailScreen extends StatefulWidget {
  final String userId;
  const SpecialistDetailScreen({super.key, required this.userId});

  @override
  State<SpecialistDetailScreen> createState() => _SpecialistDetailScreenState();
}

class _SpecialistDetailScreenState extends State<SpecialistDetailScreen> {
  bool toggleReviewField = false;
  bool toggleLikeIcon = false;
  final ReviewService _reviewService = ReviewService();

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

  void _submitReview(context, int rating, String comment) async {
    String result = await _reviewService.submitReview(
      userId: widget.userId,
      rating: rating,
      comment: comment,
    );

    if (result == 'success') {
      setState(() => toggleReviewField = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result)),
      );
    }
  }

  // void _submitReview(int rating, String comment) async {
  //   try {
  //     final user = FirebaseAuth.instance.currentUser;
  //     if (user == null) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Authentication required')),
  //       );
  //       return;
  //     }

  //     // Get reviewer's name from Firestore
  //     final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

  //     String reviewerName = 'Anonymous';
  //     if (userDoc.exists) {
  //       reviewerName = userDoc.data()?['firstName'] ?? 'Anonymous';
  //     }
  //     // print(reviewerName);
  //     await FirebaseFirestore.instance.collection('users').doc(widget.userId).collection('reviews').add({
  //       'rating': rating,
  //       'comment': comment,
  //       'reviewerId': user.uid,
  //       'reviewerName': reviewerName,
  //       'timestamp': FieldValue.serverTimestamp(),
  //     });
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
              if (!snapshot.hasData) {
                return Center(child: const CircularProgressIndicator());
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
                              onTap: () => setState(() {
                                toggleReviewField = !toggleReviewField;
                              }),
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
                                  onSubmit: (int rating, String review) {
                                    _submitReview(context, rating, review);
                                  }),
                            SizedBox(
                              height: 18.h,
                            ),
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance.collection('users').doc(widget.userId).collection('reviews').orderBy('timestamp', descending: true).snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return Center(child: const CircularProgressIndicator());
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
                                    return buildProfessionalCard(review);
                                    // ReviewCard(review: review);
                                  },
                                );
                              },
                            ),

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
                      color: Colors.grey.withValues(alpha: 0.5),
                      child: Center(
                        child: SizedBox(
                          height: 44.3.h,
                          width: 202.w,
                          child: ReusableButton(
                            bgColor: AppColors.whiteColor,
                            color: AppColors.appBGColor,
                            text: Text('Make Appointment', style: appTextStyle15(AppColors.newThirdGrayColor)),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => MakeAppointmentScreen(specialistId: widget.userId)));
                            },
                            // onPressed: () => Navigator.pushNamed(context, '/make_appointment_screen'),
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

  Widget buildProfessionalCard(final Map<String, dynamic> review) {
    return GestureDetector(
      onTap: () {},
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
                        Row(
                          children: [
                            Text(review['reviewerName'] ?? 'Anonymous', style: appTextStyle15(AppColors.newThirdGrayColor)),
                            SizedBox(width: 5.w),
                            Text(review['reviewerLastName'] ?? 'Anonymous', style: appTextStyle15(AppColors.newThirdGrayColor)),
                          ],
                        ),
                        Row(
                          children: List.generate(
                              5,
                              (index) => Icon(
                                    index < (review['rating'] as int) ? Icons.star : Icons.star_border,
                                    color: Colors.black,
                                    size: 20.dg,
                                  )),
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
                      SizedBox(width: 250.w, child: Text(review['comment'] ?? '', style: appTextStyle15(AppColors.newThirdGrayColor))),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    formatDate(review['timestamp']?.toDate()),
                    style: appTextStyle12(),
                  ),
                ],
              ),
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
                  formatDate(review['timestamp']?.toDate()),
                  style: appTextStyle12(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String formatDate(DateTime? date) {
  if (date == null) return '';
  return DateFormat('MMM dd, yyyy').format(date);
}
