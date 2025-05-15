// import 'package:attendance_system_mobile_app/core/ui/widgets/navigation_drawer_widget.dart';
// import 'package:attendance_system_mobile_app/injection_container.dart';
// import 'package:attendance_system_mobile_app/modules/attender/features/attendance/presentation/bloc/attendance_bloc.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import '../../../../../../core/errors/bloc/error_bloc.dart';
// import '../../../../../../core/ui/widgets/dialog_box.dart';

// import '../controllers/user_view_controller.dart';

// class AuthenticatedScreen extends StatefulWidget {
//   static const routeName = '/authenticated-screen';
//   const AuthenticatedScreen({super.key});

//   @override
//   State<AuthenticatedScreen> createState() => _AuthenticatedScreenState();
// }

// class _AuthenticatedScreenState extends State<AuthenticatedScreen> {
//   @override
//   void initState() {
//     super.initState();

//     sl<AttendanceBloc>().add(AttendancePageLaunched());
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: BlocListener<ErrorBloc, ErrorState>(
//         listener: (context, state) {
//           if (state is Error) {
//             //print(state.message);
//             sl<DialogBox>().showSnackBar(context, state.message);
//           }
//         },
//         child: Scaffold(
//           appBar: getAppBar(),
//           body: getCurrentUserMenuPageView(),
//           drawer: const NavigationDrawerWidget(),
//           resizeToAvoidBottomInset: false,
//         ),
//       ),
//     );
//   }
// }
