// import 'package:attendance_system_mobile_app/injection_container.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// import '../../../../../../core/ui/widgets/dialog_box.dart';
// import '../../../../../../core/ui/widgets/loading_widget.dart';

// import '../bloc/auth/bloc/auth_bloc.dart';
// import '../bloc/navigation/bloc/navigation_bloc.dart';
// import '../controllers/auth_controller.dart';
// import '../providers/auth_data_provider.dart';
// import 'otp_form_widget.dart';

// class OtpBodyWidget extends StatelessWidget {
//   const OtpBodyWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         SizedBox(height: 20.h),
//         Center(child: Image.asset('assets/logos/logo_ak.png', fit: BoxFit.contain, height: 200.h, width: 200.w)),
//         Text(
//           'Vérification',
//           style: TextStyle(
//             fontSize: 20.sp,
//             //fontWeight: FontWeight.bold,
//             color: Colors.amber[800],
//           ),
//         ),
//         Padding(
//           padding: EdgeInsets.all(20.w),
//           child: RichText(
//             textAlign: TextAlign.justify,
//             text: TextSpan(
//               text: 'Veuillez inserer le code OTP que vous venez de recevoir par SMS au numéro ',
//               style: Theme.of(context).textTheme.bodyMedium,
//               children: <TextSpan>[
//                 TextSpan(
//                   text: sl<AuthDataProvider>().user.phone,
//                   style: TextStyle(color: Colors.blueAccent, fontSize: 14.sp),
//                   // recognizer: TapGestureRecognizer()
//                   //   ..onTap = () {
//                   //     // navigate to desired screen
//                   //   }
//                 ),
//               ],
//             ),
//           ),
//         ),
//         const OtpFormWidget(),
//         SizedBox(height: 10.h),
//         BlocConsumer<AuthBloc, AuthState>(
//           listener: (context, state) {
//             if (state is AuthError) {
//               sl<DialogBox>().showSnackBar(context, state.message);
//             } else if (state is AuthResendSuccess) {
//               sl<DialogBox>().showSnackBar(context, "Code renvoyé avec succès");
//             }
//           },
//           builder: (context, state) {
//             if (state is AuthResendLoading) {
//               return Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 // crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   //SizedBox(width: 20.w),
//                   const Text("Vous n'avez pas reçu le SMS?"),
//                   TextButton(
//                     style: TextButton.styleFrom(
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0.r)),
//                       foregroundColor: Colors.blueAccent,
//                       textStyle: TextStyle(fontSize: 13.0.sp, fontStyle: FontStyle.italic),
//                       alignment: Alignment.center,
//                       //padding: EdgeInsets.fromLTRB(6.w, 0.h, 6.w, 0.h),
//                     ),
//                     onPressed: null,
//                     child: const Text("Renvoyez"),
//                   ),
//                 ],
//               );
//             }
//             return Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               // crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 //SizedBox(width: 20.w),
//                 const Text("Vous n'avez pas reçu le SMS?"),
//                 TextButton(
//                   style: TextButton.styleFrom(
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0.r)),
//                     foregroundColor: Colors.blueAccent,
//                     textStyle: TextStyle(fontSize: 13.0.sp, fontStyle: FontStyle.italic),
//                     alignment: Alignment.center,
//                     //padding: EdgeInsets.fromLTRB(6.w, 0.h, 6.w, 0.h),
//                   ),
//                   onPressed: () {
//                     sl<AuthBloc>().add(AuthLoginButtonPressed());
//                   },
//                   child: const Text("Renvoyez"),
//                 ),
//               ],
//             );
//           },
//         ),
//         BlocConsumer<AuthBloc, AuthState>(
//           listener: (context, state) {
//             if (state is AuthError) {
//               sl<DialogBox>().showSnackBar(context, state.message);
//             }
//           },
//           builder: (context, state) {
//             if (state is AuthVeriyLoading) {
//               return const LoadingWidget();
//             }
//             return ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0.r)),
//                 alignment: Alignment.center,
//                 padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 8.h),
//               ),
//               onPressed: () {
//                 FocusScopeNode currentFocus = FocusScope.of(context);

//                 if (!currentFocus.hasPrimaryFocus) {
//                   currentFocus.unfocus();
//                 }
//                 if (sl<AuthController>().checkOtpValidation()) {
//                   sl<AuthBloc>().add(AuthVerifyButtonPressed());
//                 }
//               },
//               child: Text(
//                 'Vérifier',
//                 style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14.0.sp),
//               ),
//             );
//           },
//         ),
//         TextButton(
//           style: TextButton.styleFrom(
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0.r)),
//             foregroundColor: Colors.blueAccent,
//             textStyle: TextStyle(
//               fontSize: 13.0.sp,
//               //fontStyle: FontStyle.italic,
//             ),
//             alignment: Alignment.center,
//             //padding: EdgeInsets.fromLTRB(6.w, 0.h, 6.w, 0.h),
//           ),
//           onPressed: () {
//             // sl<AuthRamDS>().isFromLogin = true;
//             sl<NavigationBloc>().add(NavigationLoginButtonPressed());
//           },
//           child: const Text("Annuler"),
//         ),
//       ],
//     );
//   }
// }
