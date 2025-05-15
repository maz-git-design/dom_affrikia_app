// import 'package:attendance_system_mobile_app/injection_container.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:pin_code_fields/pin_code_fields.dart';

// import '../controllers/auth_controller.dart';

// class OtpFormWidget extends StatefulWidget {
//   const OtpFormWidget({super.key});

//   @override
//   State<OtpFormWidget> createState() => _OtpFormWidgetState();
// }

// class _OtpFormWidgetState extends State<OtpFormWidget> {
//   TextEditingController otpCodeController = TextEditingController();
//   @override
//   Widget build(BuildContext context) {
//     return Form(
//       key: sl<AuthController>().otpFormKey,
//       child: Padding(
//         padding: const EdgeInsets.all(30),
//         child: PinCodeTextField(
//           length: 6,
//           appContext: context,
//           obscureText: false,
//           enabled: true,
//           animationType: AnimationType.fade,
//           pinTheme: PinTheme(
//             shape: PinCodeFieldShape.box,
//             borderRadius: BorderRadius.circular(20),
//             fieldHeight: 40.h,
//             fieldWidth: 38.w,
//             activeFillColor: Theme.of(context).scaffoldBackgroundColor,
//             activeColor: Theme.of(context).primaryColor,
//             disabledColor: Colors.grey,
//             inactiveColor: Colors.transparent,
//             inactiveFillColor: Colors.grey.shade200,
//             selectedFillColor: Theme.of(context).primaryColor,
//             selectedColor: Colors.transparent,
//           ),
//           animationDuration: const Duration(milliseconds: 300),
//           showCursor: false,
//           pastedTextStyle: const TextStyle(color: Colors.white),
//           backgroundColor: Colors.transparent,
//           enableActiveFill: true,
//           //errorAnimationController: errorController,
//           controller: otpCodeController,
//           keyboardType: TextInputType.number,
//           textInputAction: TextInputAction.done,
//           validator: (value) {
//             return otpCodeController.text.length < 6 ? "Le code est requis" : null;
//           },
//           onChanged: (String value) {
//             sl<AuthController>().otpController.text = value;
//           },
//         ),
//       ),
//     );
//   }
// }
