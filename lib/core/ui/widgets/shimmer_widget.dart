// import 'package:attendance_system_mobile_app/injection_container.dart';
// import 'package:flutter/material.dart';
// import 'package:shimmer/shimmer.dart';

// import '../themes/app_themes.dart';

// class ShimmerWidget extends StatelessWidget {
//   final double width;
//   final double height;
//   final ShapeBorder shapeBorder;

//   const ShimmerWidget.rectangular({this.width = double.infinity, required this.height})
//     : shapeBorder = const RoundedRectangleBorder();

//   const ShimmerWidget.circular({required this.width, required this.height, this.shapeBorder = const CircleBorder()});

//   @override
//   Widget build(BuildContext context) {
//     return Shimmer.fromColors(
//       baseColor: Theme.of(context).cardColor,
//       highlightColor: Theme.of(context).canvasColor,
//       child: Container(
//         height: height,
//         width: width,
//         decoration: ShapeDecoration(
//           color: sl<AppThemes>().isCurrentThemeModeDark ? Colors.grey.shade700 : Colors.grey.shade400,
//           shape: shapeBorder,
//         ),
//       ),
//     );
//   }
// }
