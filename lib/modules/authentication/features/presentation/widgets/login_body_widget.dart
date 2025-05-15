// import 'package:attendance_system_mobile_app/core/ui/widgets/dialog_box.dart';
// import 'package:attendance_system_mobile_app/injection_container.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// import '../../../../../../core/ui/widgets/loading_widget.dart';
// import '../bloc/auth/bloc/auth_bloc.dart';
// import '../bloc/navigation/bloc/navigation_bloc.dart';
// import '../controllers/auth_controller.dart';
// import 'login_form_widget.dart';

// class LoginBodyWidget extends StatelessWidget {
//   const LoginBodyWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           SizedBox(height: 50.h),
//           Center(child: Image.asset('assets/logos/app-logo.png', fit: BoxFit.contain, height: 120.h, width: 120.w)),

//           Text(
//             'eLandela app',
//             style: TextStyle(
//               fontSize: 30.sp,
//               //fontWeight: FontWeight.bold,
//               color: Theme.of(context).primaryColor,
//             ),
//           ),
//           SizedBox(height: 10.h),
//           Text(
//             'Se connecter',
//             style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
//           ),
//           Padding(
//             padding: EdgeInsets.all(20.w),
//             child: Text(
//               'Renseignez les champs ci-dessous pour la connexion',
//               style: TextStyle(fontSize: 13.sp),
//               textAlign: TextAlign.justify,
//             ),
//           ),
//           const LoginFormWidget(),
//           SizedBox(height: 20.h),
//           // Padding(
//           //   padding: EdgeInsets.fromLTRB(20.w, 0.h, 6.w, 0.h),
//           //   child: Align(
//           //     alignment: Alignment.centerLeft,
//           //     child: TextButton(
//           //       style: TextButton.styleFrom(
//           //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0.r)),
//           //         foregroundColor: Colors.blueAccent,
//           //         textStyle: TextStyle(fontSize: 13.0.sp),
//           //         alignment: Alignment.center,
//           //         padding: EdgeInsets.fromLTRB(6.w, 0.h, 6.w, 0.h),
//           //       ),
//           //       onPressed: () {
//           //         // sl<AuthRamDS>().isFromLogin = true;
//           //         sl<NavigationBloc>().add(NavigationForgotPasswordButtonPressed());
//           //       },
//           //       child: const Text("Mot de passe oublié?"),
//           //     ),
//           //   ),
//           // ),
//           BlocConsumer<AuthBloc, AuthState>(
//             listener: (context, state) {
//               if (state is AuthError) {
//                 sl<DialogBox>().showSnackBar(context, state.message);
//               }
//             },
//             builder: (context, state) {
//               if (state is AuthLoginLoading) {
//                 return const LoadingWidget();
//               }

//               return ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0.r)),
//                   alignment: Alignment.center,
//                   padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 8.h),
//                   backgroundColor: Theme.of(context).primaryColor,
//                 ),
//                 onPressed: () {
//                   FocusScopeNode currentFocus = FocusScope.of(context);

//                   if (!currentFocus.hasPrimaryFocus) {
//                     currentFocus.unfocus();
//                   }
//                   if (sl<AuthController>().checkLoginValidation()) {
//                     sl<AuthBloc>().add(AuthLoginButtonPressed());
//                   }
//                 },
//                 child: Text(
//                   'Connexion',
//                   style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14.0.sp),
//                 ),
//               );
//             },
//           ),
//           SizedBox(height: 10.h),
//           // Row(
//           //   mainAxisAlignment: MainAxisAlignment.center,
//           //   // crossAxisAlignment: CrossAxisAlignment.center,
//           //   children: [
//           //     //SizedBox(width: 20.w),
//           //     const Text("Vous n'avez pas un compte?"),

//           //     TextButton(
//           //       style: TextButton.styleFrom(
//           //         shape: RoundedRectangleBorder(
//           //           borderRadius: BorderRadius.circular(5.0.r),
//           //         ),
//           //         foregroundColor: Colors.blueAccent,
//           //         textStyle: TextStyle(
//           //           fontSize: 13.0.sp,
//           //           fontStyle: FontStyle.italic,
//           //         ),
//           //         alignment: Alignment.center,
//           //       ),
//           //       onPressed: () {
//           //         // sl<AuthRamDS>().isFromLogin = true;
//           //         sl<NavigationBloc>().add(NavigationSignupButtonPressed());
//           //       },
//           //       child: const Text("Créer un compte"),
//           //     ),
//           //   ],
//           // ),
//         ],
//       ),
//     );
//   }
// }
