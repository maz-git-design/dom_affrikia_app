// import 'package:attendance_system_mobile_app/core/validators/validator_mixin.dart';
// import 'package:attendance_system_mobile_app/injection_container.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// import '../controllers/auth_controller.dart';

// class LoginFormWidget extends StatefulWidget {
//   const LoginFormWidget({super.key});

//   @override
//   State<LoginFormWidget> createState() => _LoginFormWidgetState();
// }

// class _LoginFormWidgetState extends State<LoginFormWidget> with ValidatorMixin {
//   bool _isPasswordVisible = true;
//   @override
//   Widget build(BuildContext context) {
//     return Form(
//       key: sl<AuthController>().loginFormKey,
//       autovalidateMode: AutovalidateMode.onUserInteraction,
//       child: Padding(
//         padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
//         child: Column(
//           children: [
//             TextFormField(
//               decoration: InputDecoration(
//                 isDense: false,
//                 contentPadding: EdgeInsets.all(5.h),
//                 border: UnderlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(8.0.r)),
//                 focusedBorder: UnderlineInputBorder(
//                   borderSide: BorderSide.none,
//                   borderRadius: BorderRadius.circular(8.0.r),
//                 ),
//                 enabledBorder: UnderlineInputBorder(
//                   borderSide: BorderSide.none,
//                   borderRadius: BorderRadius.circular(8.0.r),
//                 ),
//                 errorBorder: UnderlineInputBorder(
//                   borderSide: BorderSide.none,
//                   borderRadius: BorderRadius.circular(8.0.r),
//                 ),
//                 disabledBorder: InputBorder.none,
//                 // fillColor: Colors.grey[200],
//                 filled: true,
//                 label: Text("E-mail", style: TextStyle(fontSize: 14.sp)),
//                 hintText: "Entrer l'e-mail",
//                 labelStyle: TextStyle(color: Colors.grey, fontSize: 12.5.sp),
//                 prefixIcon: const Icon(Icons.email),
//                 //prefixText: '+243 ',
//                 prefixStyle: TextStyle(fontSize: 12.sp),
//               ),
//               style: TextStyle(fontSize: 12.sp),
//               keyboardType: TextInputType.emailAddress,
//               textInputAction: TextInputAction.next,
//               controller: sl<AuthController>().emailAddress,
//               validator: (value) {
//                 return validateEmail(value!);
//               },
//               // onChanged: (value) {
//               //   setState(() {});
//               // },
//             ),
//             SizedBox(height: 10.h),
//             TextFormField(
//               decoration: InputDecoration(
//                 isDense: false,
//                 contentPadding: EdgeInsets.all(5.h),
//                 border: UnderlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(8.0.r)),
//                 focusedBorder: UnderlineInputBorder(
//                   borderSide: BorderSide.none,
//                   borderRadius: BorderRadius.circular(8.0.r),
//                 ),
//                 enabledBorder: UnderlineInputBorder(
//                   borderSide: BorderSide.none,
//                   borderRadius: BorderRadius.circular(8.0.r),
//                 ),
//                 errorBorder: UnderlineInputBorder(
//                   borderSide: BorderSide.none,
//                   borderRadius: BorderRadius.circular(8.0.r),
//                 ),
//                 disabledBorder: InputBorder.none,
//                 // fillColor: Colors.grey[200],
//                 filled: true,
//                 label: Text("Mot de passe", style: TextStyle(fontSize: 14.sp)),
//                 hintText: "Entrer le mot de passe",
//                 labelStyle: TextStyle(color: Colors.grey, fontSize: 12.5.sp),
//                 prefixIcon: const Icon(Icons.lock),
//                 suffixIcon: IconButton(
//                   onPressed: () {
//                     setState(() {
//                       _isPasswordVisible = !_isPasswordVisible;
//                     });
//                   },
//                   icon: _isPasswordVisible ? const Icon(Icons.visibility) : const Icon(Icons.visibility_off),
//                   splashRadius: 20.r,
//                 ),
//                 prefixStyle: TextStyle(fontSize: 12.sp),
//               ),
//               obscureText: _isPasswordVisible,
//               style: TextStyle(fontSize: 12.sp),
//               keyboardType: TextInputType.text,
//               textInputAction: TextInputAction.done,
//               controller: sl<AuthController>().passwordController,
//               validator: (value) {
//                 return validatePassword(value);
//               },
//               // onChanged: (value) {
//               //   setState(() {});
//               // },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
