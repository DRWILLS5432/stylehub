import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:stylehub/constants/app/app_colors.dart';
import 'package:stylehub/constants/app/textstyle.dart';
import 'package:stylehub/constants/localization/locales.dart';
import 'package:stylehub/screens/specialist_pages/model/specialist_model.dart';
import 'package:stylehub/screens/specialist_pages/provider/location_provider.dart';
import 'package:stylehub/screens/specialist_pages/specialist_detail_screen.dart';
import 'package:stylehub/storage/likes_method.dart';

class LikesScreen extends StatefulWidget {
  const LikesScreen({super.key});

  @override
  State<LikesScreen> createState() => _LikesScreenState();
}

class _LikesScreenState extends State<LikesScreen> {
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final addressProvider = Provider.of<AddressProvider>(context, listen: false);
      await addressProvider.fetchAddresses();

      if (addressProvider.selectedAddress != null) {
        final selectedAddress = addressProvider.selectedAddress!;
        setState(() {
          _currentPosition = Position(
            latitude: selectedAddress.lat ?? 0,
            longitude: selectedAddress.lng ?? 0,
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0,
            altitudeAccuracy: 0,
            headingAccuracy: 0,
          );
        });
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  double _calculateDistance(SpecialistModel specialist) {
    if (_currentPosition == null || specialist.lat == null || specialist.lng == null) return 0;

    return Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          specialist.lat!,
          specialist.lng!,
        ) /
        1000; // Convert meters to kilometers
  }

  String _formatDistance(double km) {
    if (km < 1) return '${(km * 1000).round()}m';
    return '${km.toStringAsFixed(1)}km';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Text(
          LocaleData.likes.getString(context),
          style: appTextStyle24(AppColors.newThirdGrayColor),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20.w),
            child: Icon(Icons.favorite, color: AppColors.primaryRedColor),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: LikeService().getFavorites(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No favorites found',
                style: appTextStyle16(AppColors.newThirdGrayColor),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(doc['specialistId']).get(),
                builder: (context, specialistSnapshot) {
                  if (!specialistSnapshot.hasData) {
                    return SizedBox.shrink();
                  }

                  final specialist = SpecialistModel.fromFirestore(specialistSnapshot.data!);
                  final distance = _calculateDistance(specialist);

                  return buildProfessionalCard(
                    context,
                    specialist,
                    distance,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget buildProfessionalCard(
    BuildContext context,
    SpecialistModel user,
    double distance,
  ) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      color: Color(0xFFD7D1BE),
      child: Padding(
        padding: EdgeInsets.all(16.w),
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
                    backgroundImage: user.profileImage != null ? MemoryImage(base64Decode(user.profileImage!)) : AssetImage('assets/master1.png') as ImageProvider,
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
                            index < user.averageRating.floor() ? Icons.star : Icons.star_border,
                            color: Colors.black,
                            size: 20,
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
                    Text(
                      _formatDistance(distance),
                      style: appTextStyle15(AppColors.newThirdGrayColor),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SpecialistDetailScreen(
                          userId: user.userId,
                          name: user.fullName,
                          rating: user.averageRating,
                          distance: distance,
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

// import 'dart:convert';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_localization/flutter_localization.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:stylehub/constants/app/app_colors.dart';
// import 'package:stylehub/constants/app/textstyle.dart';
// import 'package:stylehub/constants/localization/locales.dart';
// import 'package:stylehub/screens/specialist_pages/model/specialist_model.dart';
// import 'package:stylehub/screens/specialist_pages/specialist_detail_screen.dart';
// import 'package:stylehub/storage/fire_store_method.dart';
// import 'package:stylehub/storage/likes_method.dart';

// class LikesScreen extends StatelessWidget {
//   const LikesScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.whiteColor,
//       appBar: AppBar(
//         backgroundColor: AppColors.whiteColor,
//         automaticallyImplyLeading: false,
//         centerTitle: false,
//         title: Text(
//           LocaleData.likes.getString(context),
//           style: appTextStyle24(AppColors.newThirdGrayColor),
//         ),
//         actions: [
//           Padding(
//             padding: EdgeInsets.only(right: 20.w),
//             child: Icon(Icons.favorite),
//           )
//         ],
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: LikeService().getFavorites(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }

//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return Center(child: Text('No favorites yet'));
//           }

//           final favorites = snapshot.data!.docs;

//           return Column(
//             children: [
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: favorites.length,
//                   itemBuilder: (context, index) {
//                     final favoriteData = favorites[index].data() as Map<String, dynamic>;

//                     // Create a simplified specialist model from the favorite data
//                     final specialist = SpecialistModel(
//                         userId: favoriteData['specialistId'],
//                         firstName: favoriteData['specialistName'],
//                         lastName: favoriteData['specialistLastName'],
//                         profileImage: favoriteData['profileImage'],
//                         role: favoriteData['role'],
//                         email: '',
//                         bio: '',
//                         experience: '',
//                         city: '',
//                         address: '',
//                         phone: '',
//                         categories: [],
//                         images: [],
//                         services: [],
//                         isAvailable: false,
//                         averageRating: 0
//                         // Other fields can be added if needed
//                         );

//                     return FutureBuilder<double>(
//                       future: FireStoreMethod().getAverageRating(specialist.userId),
//                       builder: (context, ratingSnapshot) {
//                         if (!ratingSnapshot.hasData) {
//                           return SizedBox.shrink();
//                         }

//                         if (ratingSnapshot.data == null) {
//                           return Center(child: CircularProgressIndicator());
//                         }

//                         double averageRating = ratingSnapshot.data ?? 0.0;
//                         // final distance = _calculateDistance(specialist);

//                         return buildProfessionalCard(
//                           context,
//                           specialist,
//                           averageRating,
//                           distance.toString(),
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ),
//               SizedBox(
//                 height: 70.h,
//               )
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

// Widget buildProfessionalCard(
//   BuildContext context,
//   SpecialistModel user,
//   double averageRating,
//   String? distance,
// ) {
//   return Card(
//     margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
//     color: Color(0xFFD7D1BE),
//     child: Padding(
//       padding: EdgeInsets.only(left: 17.w, right: 17.h, top: 29.h, bottom: 12.h),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: EdgeInsets.all(2.dg),
//                 decoration: BoxDecoration(
//                   color: AppColors.whiteColor,
//                   borderRadius: BorderRadius.circular(100.dg),
//                 ),
//                 child: CircleAvatar(
//                   radius: 60.dg,
//                   backgroundImage: user.profileImage != null ? MemoryImage(base64Decode(user.profileImage!)) : AssetImage('assets/master1.png') as ImageProvider,
//                 ),
//               ),
//               SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(user.fullName, style: appTextStyle20(AppColors.newThirdGrayColor)),
//                     Text(
//                       user.role,
//                       style: appTextStyle15(AppColors.newThirdGrayColor),
//                     ),
//                     SizedBox(height: 8),
//                     Row(
//                       children: List.generate(
//                         5,
//                         (index) => Icon(
//                           index < averageRating.floor() ? Icons.star : Icons.star_border,
//                           color: Colors.black,
//                           size: 20,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 10.h),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   Icon(Icons.location_pin, color: AppColors.newThirdGrayColor),
//                   Text("70m", style: appTextStyle15(AppColors.newThirdGrayColor)),
//                 ],
//               ),
//               TextButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => SpecialistDetailScreen(
//                         userId: user.userId,
//                         name: user.fullName,
//                         rating: averageRating,
//                         distance: double.parse(distance ?? '0'),
//                       ),
//                     ),
//                   );
//                 },
//                 child: Text(
//                   LocaleData.view.getString(context),
//                   style: appTextStyle14(AppColors.newThirdGrayColor),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     ),
//   );
// }
