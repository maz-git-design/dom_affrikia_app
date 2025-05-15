// import 'dart:async';


// import 'package:flutter/material.dart';
// import 'package:get_it/get_it.dart';

// import '../../domain/entities/user.dart';

// class AuthController extends Disposable {
//   @override
//   FutureOr onDispose() {
//     return Future(() {});
//   }

//   TextEditingController phoneNumberController = TextEditingController();
//   TextEditingController editPhoneNumberController = TextEditingController();
//   TextEditingController passwordController = TextEditingController();
//   TextEditingController nameController = TextEditingController();
//   TextEditingController editNameController = TextEditingController();
//   TextEditingController emailAddress = TextEditingController();
//   TextEditingController editEmailAddress = TextEditingController();
//   TextEditingController confirmPasswordController = TextEditingController();
//   TextEditingController otpController = TextEditingController();
//   TextEditingController otpResetController = TextEditingController();
//   String profilController = "enterprise";

//   GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
//   GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();
//   GlobalKey<FormState> resetPasswordFormKey = GlobalKey<FormState>();
//   GlobalKey<FormState> sendResetCodeFormKey = GlobalKey<FormState>();
//   GlobalKey<FormState> verificationFormKey = GlobalKey<FormState>();
//   GlobalKey<FormState> editFormKey = GlobalKey<FormState>();
//   GlobalKey<FormState> otpFormKey = GlobalKey<FormState>();

//   // List<UserProfil> profiles = [
//   //   const UserProfil(code: "enterprise", name: "Entreprise"),
//   //   const UserProfil(code: "user", name: "Particulier"),
//   //   const UserProfil(code: "deliverboy", name: "Livreur")
//   // ];

//   User get user => User(email: emailAddress.text, password: passwordController.text);

//   User get userToEdit => User(
//     id: sl<AuthDataProvider>().user.id,
//     name: editNameController.text,
//     phone: "+243${editPhoneNumberController.text}",
//     email: editEmailAddress.text,
//   );

//   void putCurrentProfil() {
//     editNameController.text = sl<AuthDataProvider>().user.name ?? '';
//     editPhoneNumberController.text = sl<AuthDataProvider>().user.phone?.substring(4) ?? '';
//     editEmailAddress.text = sl<AuthDataProvider>().user.email ?? '';
//   }

//   bool checkLoginValidation() {
//     bool isValidate;
//     if (loginFormKey.currentState != null) {
//       isValidate = loginFormKey.currentState!.validate();

//       if (!isValidate) {
//         return false;
//       }
//       loginFormKey.currentState!.save();
//       return true;
//     } else {
//       return false;
//     }
//   }

//   bool checkSignupValidation() {
//     bool isValidate;
//     if (signupFormKey.currentState != null) {
//       isValidate = signupFormKey.currentState!.validate();

//       if (!isValidate) {
//         return false;
//       }
//       signupFormKey.currentState!.save();
//       return true;
//     } else {
//       return false;
//     }
//   }

//   bool checkEditValidation() {
//     bool isValidate;
//     if (editFormKey.currentState != null) {
//       isValidate = editFormKey.currentState!.validate();

//       if (!isValidate) {
//         return false;
//       }
//       editFormKey.currentState!.save();
//       return true;
//     } else {
//       return false;
//     }
//   }

//   bool checkReSendResetCodeValidation() {
//     bool isValidate;
//     if (sendResetCodeFormKey.currentState != null) {
//       isValidate = sendResetCodeFormKey.currentState!.validate();

//       if (!isValidate) {
//         return false;
//       }
//       sendResetCodeFormKey.currentState!.save();
//       return true;
//     } else {
//       return false;
//     }
//   }

//   bool checkResetPasswordValidation() {
//     bool isValidate;
//     if (resetPasswordFormKey.currentState != null) {
//       isValidate = resetPasswordFormKey.currentState!.validate();

//       if (!isValidate) {
//         return false;
//       }
//       resetPasswordFormKey.currentState!.save();
//       return true;
//     } else {
//       return false;
//     }
//   }

//   bool checkOtpValidation() {
//     bool isValidate;
//     if (otpFormKey.currentState != null) {
//       isValidate = otpFormKey.currentState!.validate();

//       if (!isValidate) {
//         return false;
//       }
//       otpFormKey.currentState!.save();
//       return true;
//     } else {
//       return false;
//     }
//   }
// }
