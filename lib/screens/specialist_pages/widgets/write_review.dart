import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stylehub/constants/app/app_colors.dart';
import 'package:stylehub/constants/app/textstyle.dart';
import 'package:stylehub/constants/localization/locales.dart';

class WriteReviewWidget extends StatefulWidget {
  const WriteReviewWidget({
    super.key,
    required this.toggleReviewField,
    required this.onSubmit,
  });

  final bool toggleReviewField;
  final Function(int rating, String comment) onSubmit;

  @override
  State<WriteReviewWidget> createState() => _WriteReviewWidgetState();
}

class _WriteReviewWidgetState extends State<WriteReviewWidget> {
  final TextEditingController _reviewController = TextEditingController();
  int _selectedRating = 0;
  bool _isLoading = false;

  Future<void> _submitReview() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    
    try {
      if (_selectedRating == 0) {
        throw 'Please select a rating';
      }
      if (_reviewController.text.isEmpty) {
        throw 'Please write a review';
      }
      
      await widget.onSubmit(_selectedRating, _reviewController.text);
      
      _reviewController.clear();
      setState(() => _selectedRating = 0);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: widget.toggleReviewField ? 1 : 0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(10.dg),
          border: Border.all(color: AppColors.appBGColor, width: 3.h),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              LocaleData.howDidItGo.getString(context),
              style: appTextStyle15600(AppColors.newThirdGrayColor),
            ),
            SizedBox(height: 8.h),
            Text(
              LocaleData.takeAMomentToRate.getString(context),
              style: appTextStyle11500(AppColors.newThirdGrayColor),
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) => GestureDetector(
                onTap: () => setState(() => _selectedRating = index + 1),
                child: Icon(
                  index < _selectedRating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 30,
                ),
              )),
            ),
            SizedBox(height: 20.h),
            TextFormField(
              controller: _reviewController,
              decoration: InputDecoration(
                hintText: LocaleData.writeYourRevHere.getString(context),
                suffixIcon: _isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: Image.asset('assets/images/PaperPlane.png'),
                        onPressed: _submitReview,
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.dg),
                  borderSide: BorderSide(
                    color: AppColors.appBGColor,
                    width: 2.h,
                  ),
                ),
              ),
              maxLines: 3,
              minLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}