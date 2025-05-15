import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NodataWidget extends StatelessWidget {
  const NodataWidget({
    super.key,
    required this.size,
    required this.fontSize,
    required this.spacing,
  });

  final double size;
  final double fontSize;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return ListView(
      //mainAxisAlignment: MainAxisAlignment.center,
      physics: const BouncingScrollPhysics(),
      children: [
        Center(
          child: Image.asset(
            'assets/images/nodata.png',
            fit: BoxFit.contain,
            height: size.h,
            width: size.w,
          ),
        ),
        SizedBox(height: spacing.h),
        Center(
          child: Text(
            "Désolé!",
            style: TextStyle(fontSize: fontSize.sp),
          ),
        ),
        Center(
          child: Text(
            "Pas de données trouvées",
            style: TextStyle(fontSize: fontSize.sp, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
