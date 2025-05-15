// import 'package:attendance_system_mobile_app/modules/authentication/features/presentation/bloc/navigation/bloc/navigation_bloc.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import '../widgets/login_body_widget.dart';
// import '../widgets/otp_body_widget.dart';

// class HomeScreen extends StatelessWidget {
//   static const routeName = '/home-screen';
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: BlocBuilder<NavigationBloc, NavigationState>(
//         builder: (context, state) {
//           if (state is NavigationLogin) {
//             return const LoginBodyWidget();
//           } else if (state is NavigationOtp) {
//             return const OtpBodyWidget();
//           }
//           return const LoginBodyWidget();
//         },
//       ),
//     );
//   }
// }
