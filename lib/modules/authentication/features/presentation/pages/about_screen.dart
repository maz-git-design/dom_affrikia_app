// import 'package:attendance_system_mobile_app/core/ui/widgets/about_app_bar.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// class AboutScreen extends StatelessWidget {
//   static const routeName = '/about-screen';
//   const AboutScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: const AboutAppBar(),
//       body: Column(
//         children: [
//           SizedBox(height: 10.h),
//           Center(child: Image.asset('assets/logos/logo.png', fit: BoxFit.contain, height: 200.h, width: 200.w)),
//           Container(
//             margin: const EdgeInsets.symmetric(horizontal: 20),
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               shape: BoxShape.rectangle,
//               borderRadius: BorderRadius.circular(10),
//               border: Border.all(width: 2, color: Theme.of(context).primaryColor),
//             ),
//             child: Column(
//               children: [
//                 Text(
//                   "WEWA Express is a leading logistics company. Our 2,000 deliverers work every day to help you cross borders, reach new markets and grow your business.",
//                   textAlign: TextAlign.justify,
//                   style: TextStyle(color: Colors.black87, fontSize: 14.sp, fontWeight: FontWeight.bold),
//                 ),
//                 SizedBox(height: 10.h),
//                 const Align(
//                   alignment: Alignment.centerLeft,
//                   child: Text("Snippet By Bootstrapious", textAlign: TextAlign.justify),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
