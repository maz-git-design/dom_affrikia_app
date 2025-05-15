// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:wewaexpress/core/ui/widgets/dialog_box.dart';
// import 'package:wewaexpress/core/ui/widgets/loading_widget.dart';

// import '../../../injection_container.dart';
// import '../../../modules/authentication/features/auth/presentation/bloc/auth/bloc/auth_bloc.dart';
// import '../../../modules/authentication/features/auth/presentation/controllers/auth_controller.dart';
// import '../../validators/validator_mixin.dart';

// class EditProfilForm extends StatelessWidget with ValidatorMixin {
//   const EditProfilForm({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Form(
//       key: sl<AuthController>().editFormKey,
//       autovalidateMode: AutovalidateMode.onUserInteraction,
//       child: Padding(
//         padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
//         child: SingleChildScrollView(
//           physics: const BouncingScrollPhysics(),
//           //keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
//           child: ConstrainedBox(
//             constraints: BoxConstraints(
//               minWidth: MediaQuery.of(context).size.width,
//               minHeight: MediaQuery.of(context).size.height * 0.8,
//             ),
//             child: Column(
//               children: [
//                 TextFormField(
//                   decoration: InputDecoration(
//                     isDense: false,
//                     contentPadding: EdgeInsets.all(5.h),
//                     border: UnderlineInputBorder(
//                       borderSide: BorderSide.none,
//                       borderRadius: BorderRadius.circular(8.0.r),
//                     ),
//                     focusedBorder: UnderlineInputBorder(
//                       borderSide: BorderSide.none,
//                       borderRadius: BorderRadius.circular(8.0.r),
//                     ),
//                     enabledBorder: UnderlineInputBorder(
//                       borderSide: BorderSide.none,
//                       borderRadius: BorderRadius.circular(8.0.r),
//                     ),
//                     errorBorder: UnderlineInputBorder(
//                       borderSide: BorderSide.none,
//                       borderRadius: BorderRadius.circular(8.0.r),
//                     ),
//                     disabledBorder: InputBorder.none,
//                     filled: true,
//                     label: Text(
//                       "Nom",
//                       style: TextStyle(fontSize: 14.sp),
//                     ),
//                     hintText: "Entrer le nom",
//                     labelStyle:
//                         TextStyle(color: Colors.grey, fontSize: 12.5.sp),
//                     prefixIcon: const Icon(Icons.person),
//                     prefixStyle: TextStyle(fontSize: 12.sp),
//                   ),
//                   style: TextStyle(fontSize: 12.sp),
//                   keyboardType: TextInputType.name,
//                   textInputAction: TextInputAction.next,
//                   controller: sl<AuthController>().editNameController,
//                   validator: (value) {
//                     return validateName(value);
//                   },
//                   // onChanged: (value) {
//                   //   setState(() {});
//                   // },
//                 ),
//                 SizedBox(height: 10.h),
//                 TextFormField(
//                   decoration: InputDecoration(
//                     isDense: false,
//                     contentPadding: EdgeInsets.all(5.h),
//                     border: UnderlineInputBorder(
//                       borderSide: BorderSide.none,
//                       borderRadius: BorderRadius.circular(8.0.r),
//                     ),
//                     focusedBorder: UnderlineInputBorder(
//                       borderSide: BorderSide.none,
//                       borderRadius: BorderRadius.circular(8.0.r),
//                     ),
//                     enabledBorder: UnderlineInputBorder(
//                       borderSide: BorderSide.none,
//                       borderRadius: BorderRadius.circular(8.0.r),
//                     ),
//                     errorBorder: UnderlineInputBorder(
//                       borderSide: BorderSide.none,
//                       borderRadius: BorderRadius.circular(8.0.r),
//                     ),
//                     disabledBorder: InputBorder.none,
//                     filled: true,
//                     label: Text(
//                       "Téléphone",
//                       style: TextStyle(fontSize: 14.sp),
//                     ),
//                     hintText: "Entrer le numéro",
//                     labelStyle:
//                         TextStyle(color: Colors.grey, fontSize: 12.5.sp),
//                     prefixIcon: const Icon(Icons.phone),
//                     prefixText: '+243 ',
//                     prefixStyle: TextStyle(fontSize: 12.sp),
//                   ),
//                   style: TextStyle(fontSize: 12.sp),
//                   keyboardType: TextInputType.phone,
//                   textInputAction: TextInputAction.next,
//                   controller: sl<AuthController>().editPhoneNumberController,
//                   validator: (value) {
//                     return validateMobileNumber(value);
//                   },
//                   // onChanged: (value) {
//                   //   setState(() {});
//                   // },
//                 ),
//                 SizedBox(height: 10.h),
//                 TextFormField(
//                   decoration: InputDecoration(
//                     isDense: false,
//                     contentPadding: EdgeInsets.all(5.h),
//                     border: UnderlineInputBorder(
//                       borderSide: BorderSide.none,
//                       borderRadius: BorderRadius.circular(8.0.r),
//                     ),
//                     focusedBorder: UnderlineInputBorder(
//                       borderSide: BorderSide.none,
//                       borderRadius: BorderRadius.circular(8.0.r),
//                     ),
//                     enabledBorder: UnderlineInputBorder(
//                       borderSide: BorderSide.none,
//                       borderRadius: BorderRadius.circular(8.0.r),
//                     ),
//                     errorBorder: UnderlineInputBorder(
//                       borderSide: BorderSide.none,
//                       borderRadius: BorderRadius.circular(8.0.r),
//                     ),
//                     disabledBorder: InputBorder.none,
//                     filled: true,
//                     label: Text(
//                       "Adresse e-mail",
//                       style: TextStyle(fontSize: 14.sp),
//                     ),
//                     hintText: "Entrer l'e-mail",
//                     labelStyle:
//                         TextStyle(color: Colors.grey, fontSize: 12.5.sp),
//                     prefixIcon: const Icon(Icons.email),
//                     prefixStyle: TextStyle(fontSize: 12.sp),
//                   ),
//                   style: TextStyle(fontSize: 12.sp),
//                   keyboardType: TextInputType.emailAddress,
//                   textInputAction: TextInputAction.next,
//                   controller: sl<AuthController>().editEmailAddress,
//                   // validator: (value) {
//                   //   return validateEmail(value!);
//                   // },
//                   // onChanged: (value) {
//                   //   setState(() {});
//                   // },
//                 ),
//                 SizedBox(height: 20.h),
//                 BlocConsumer<AuthBloc, AuthState>(
//                   listener: (context, state) async {
//                     if (state is AuthError) {
//                       sl<DialogBox>().showSnackBar(context, state.message);
//                     } else if (state is AuthEditProfilSuccess) {
//                       sl<DialogBox>().showDialoxInfo(
//                           context, 'Votre Profil a été édité avec succès');

//                       //Navigator.of(context).pop();
//                     }
//                   },
//                   builder: (context, state) {
//                     if (state is AuthEditProfilLoading) {
//                       return const LoadingWidget();
//                     }
//                     return ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8.0.r),
//                         ),
//                         alignment: Alignment.center,
//                         padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 8.h),
//                       ),
//                       onPressed: () {
//                         FocusScopeNode currentFocus = FocusScope.of(context);

//                         if (!currentFocus.hasPrimaryFocus) {
//                           currentFocus.unfocus();
//                         }
//                         if (sl<AuthController>().checkEditValidation()) {
//                           sl<AuthBloc>().add(AuthEditButtonPressed());
//                         }
//                       },
//                       child: Text(
//                         'Editer',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.w800,
//                           fontSize: 14.0.sp,
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//                 SizedBox(height: 10.h),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
