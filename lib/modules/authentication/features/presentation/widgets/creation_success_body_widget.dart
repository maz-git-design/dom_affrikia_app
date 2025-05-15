// import 'package:attendance_system_mobile_app/injection_container.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// import '../bloc/navigation/bloc/navigation_bloc.dart';
// import '../controllers/auth_controller.dart';

// class CreationSuccessBodyWidget extends StatelessWidget {
//   const CreationSuccessBodyWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         SizedBox(height: 20.h),
//         Center(child: Image.asset('assets/logos/logo.png', fit: BoxFit.contain, height: 200.h, width: 200.w)),
//         Text(
//           'Création Réussie',
//           style: TextStyle(
//             fontSize: 20.sp,
//             //fontWeight: FontWeight.bold,
//             color: Colors.amber[800],
//           ),
//         ),
//         Padding(
//           padding: EdgeInsets.all(20.w),
//           child: Text(
//             'La création du compte avec le numéro ${sl<AuthController>().user.phone} a été effectuée avec succès.',
//             textAlign: TextAlign.justify,
//           ),
//         ),
//         Icon(Icons.verified, color: Theme.of(context).primaryColor, size: 80.r),
//         SizedBox(height: 10.h),
//         Container(
//           decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(10.r)),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.person),
//               SizedBox(width: 10.w),
//               Text(
//                 sl<AuthController>().user.name ?? '--',
//                 style: TextStyle(
//                   fontSize: 15.sp,
//                   //fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           padding: EdgeInsets.symmetric(vertical: 10),
//           margin: EdgeInsets.symmetric(horizontal: 20.w),
//         ),
//         SizedBox(height: 10.h),
//         Container(
//           decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(10.r)),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.phone),
//               SizedBox(width: 10.w),
//               Text(
//                 sl<AuthController>().user.phone ?? '--',
//                 style: TextStyle(
//                   fontSize: 15.sp,
//                   //fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           padding: EdgeInsets.symmetric(vertical: 10),
//           margin: EdgeInsets.symmetric(horizontal: 20.w),
//         ),
//         SizedBox(height: 30.h),
//         ElevatedButton(
//           style: ElevatedButton.styleFrom(
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0.r)),
//             alignment: Alignment.center,
//             padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 8.h),
//           ),
//           onPressed: () {
//             FocusScopeNode currentFocus = FocusScope.of(context);

//             if (!currentFocus.hasPrimaryFocus) {
//               currentFocus.unfocus();
//             }
//             sl<NavigationBloc>().add(NavigationLoginButtonPressed());
//           },
//           child: Text('Ok', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14.0.sp)),
//         ),
//         SizedBox(height: 10.h),
//       ],
//     );
//   }
// }
