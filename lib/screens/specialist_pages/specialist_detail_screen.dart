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
import 'package:stylehub/storage/likes_method.dart';
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
  String? selectedImage;
  final ReviewService _reviewService = ReviewService();
  final LikeService _likeService = LikeService();

  @override

  /// Initializes the state of the widget.
  ///
  /// Calls the superclass's `initState` method, and then fetches the services
  /// provided by the given specialist.
  void initState() {
    super.initState();
    _checkIfLiked();
  }

  Future<void> _checkIfLiked() async {
    bool hasLiked = await _likeService.hasLiked(widget.userId);
    setState(() {
      toggleLikeIcon = hasLiked;
    });
  }

  Future<void> _toggleLike() async {
    String result = await _likeService.toggleLike(widget.userId);
    if (result == 'liked' || result == 'unliked') {
      setState(() {
        toggleLikeIcon = result == 'liked';
      });
    } else {
      print(result);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result)),
      );
    }
  }

  /// Submits a review for a specialist.
  ///
  /// Submits a review with the given `rating` and `comment` for the specialist
  /// with the provided `userId`. Shows a success message if the submission is
  /// successful, and shows an error message if the submission fails.
  ///
  /// Parameters:
  /// - `context`: The BuildContext to use for showing a SnackBar.
  /// - `rating`: An integer representing the user's rating for the specialist.
  /// - `comment`: A string containing the user's comments or feedback.
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
                onTap: _toggleLike,
                child: Icon(
                  toggleLikeIcon ? Icons.favorite : Icons.favorite_border,
                  color: toggleLikeIcon ? Colors.red : AppColors.newThirdGrayColor,
                ),
              ),
            ),
          ],
        ),
        body: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('users').doc(widget.userId).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return Center(child: Text('Specialist not found'));
              }

              final userData = snapshot.data!.data() as Map<String, dynamic>;
              final profileImage = userData['profileImage'] ?? '';
              // final firstName = userData['firstName'] ?? '';
              // final lastName = userData['lastName'] ?? '';
              final bio = userData['bio'] ?? 'No bio available';
              // final role = userData['role'] ?? 'Stylist';
              // final experience = userData['experience'] ?? 'No experience info';
              // final city = userData['city'] ?? '';
              // final phone = userData['phone'] ?? '';
              // final email = userData['email'] ?? '';
              final categories = List<String>.from(userData['categories'] ?? []);
              final images = List<String>.from(userData['images'] ?? []);
              final services = List<Map<String, dynamic>>.from(userData['services'] ?? []);

              // Set default top image if it's not set
              if (selectedImage == null && images.isNotEmpty) {
                selectedImage = images[0];
              }

              return Stack(
                children: [
                  SingleChildScrollView(
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // **Big Image at the Top**
                            SizedBox(
                              width: double.maxFinite,
                              height: 304.h,
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(15.dg),
                                  bottomRight: Radius.circular(15.dg),
                                ),
                                child: selectedImage != null
                                    ? Image.network(
                                        selectedImage!,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
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
                                  StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance.collection('users').doc(widget.userId).collection('likes').snapshots(),
                                    builder: (context, snapshot) {
                                      final likeCount = snapshot.hasData ? snapshot.data!.docs.length : 0;
                                      return Row(
                                        children: [
                                          Text('5.0'.toString(), style: appTextStyle15(AppColors.newThirdGrayColor)),
                                          Icon(Icons.star, color: AppColors.mainBlackTextColor, size: 15.dg),
                                          SizedBox(width: 10.w),
                                          Icon(Icons.favorite, color: Colors.red, size: 15.dg),
                                          Text(likeCount.toString(), style: appTextStyle15(AppColors.newThirdGrayColor)),
                                        ],
                                      );
                                    },
                                  )
                                ],
                              ),
                            ),
                            SizedBox(height: 20.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15.w),
                              child: Text(LocaleData.serviceProvide.getString(context), style: appTextStyle15600(AppColors.newThirdGrayColor)),
                            ),
                            SizedBox(height: 20.h),
                            // Widget to display list of selected Categories
                            // Display categories
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              child: Wrap(
                                spacing: 12.0,
                                children: categories
                                    .map((category) => Column(
                                          children: [
                                            CircleAvatar(
                                              radius: 30.dg,
                                            ),
                                            SizedBox(
                                              height: 6.h,
                                            ),
                                            Text(category, style: appTextStyle15(AppColors.newThirdGrayColor)),
                                          ],
                                        ))
                                    .toList(),
                              ),
                            ),
                            // Widget to display services
                            SizedBox(height: 36.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15.w),
                              child: Text(LocaleData.previousWork.getString(context), style: appTextStyle15600(AppColors.newThirdGrayColor)),
                            ),
                            SizedBox(height: 20.h),
                            // Display uploaded images
                            // **Display Uploaded Images (Previous Work)**
                            images.isNotEmpty
                                ? SizedBox(
                                    height: 140,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: images.length,
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          onTap: () {
                                            // When a user taps an image, update the top image
                                            setState(() {
                                              selectedImage = images[index];
                                            });
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(110.dg),
                                                color: AppColors.appBGColor,
                                              ),
                                              padding: EdgeInsets.all(3.w),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(100.dg),
                                                child: Image.network(
                                                  images[index],
                                                  width: 120,
                                                  height: 140,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : Text('No images uploaded'),

                            SizedBox(height: 36.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15.w),
                              child: Text(LocaleData.services.getString(context), style: appTextStyle15600(AppColors.newThirdGrayColor)),
                            ),
                            SizedBox(height: 10.h), // Display services
                            Column(
                              children: services.map((service) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                                  child: Row(
                                    children: [
                                      Text(service['service'] ?? 'Service'),
                                      Spacer(),
                                      Text('-'),
                                      Spacer(),
                                      Text('Price: ${service['price']}'),
                                    ],
                                    // title: Text(service['service'] ?? 'Service'),
                                    // subtitle: Text('Price: ${service['price']}'),
                                  ),
                                );
                              }).toList(),
                            ),
                            SizedBox(height: 20.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15.w),
                              child: Text(LocaleData.bio.getString(context), style: appTextStyle15600(AppColors.newThirdGrayColor)),
                            ),
                            SizedBox(height: 10.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15.w),
                              child: Text(bio.toString(), style: appTextStyle15(AppColors.newThirdGrayColor)),
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
