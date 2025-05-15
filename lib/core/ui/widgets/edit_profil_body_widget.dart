// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// import 'edit_profil_form.dart';

// class EditProfilBodyWidget extends StatelessWidget {
//   const EditProfilBodyWidget({
//     Key? key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         SizedBox(height: 10.h),
//         Center(
//           child: Image.asset(
//             'assets/logos/logo.png',
//             fit: BoxFit.contain,
//             height: 200.h,
//             width: 200.w,
//           ),
//         ),
//         Text(
//           'Editer votre profil',
//           style: TextStyle(
//             fontSize: 20.sp,
//             color: Colors.amber[800],
//           ),
//         ),
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
//           child: const Text(
//             "Veuillez renseigner les champs ci-dessous pour pouvoir procéder à l'édition de votre compte",
//             textAlign: TextAlign.justify,
//           ),
//         ),
//         const Flexible(child: EditProfilForm()),
//         SizedBox(height: 10.h),
//       ],
//     );
//   }
// }
