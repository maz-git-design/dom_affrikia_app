// import 'package:attendance_system_mobile_app/injection_container.dart';
// import 'package:attendance_system_mobile_app/modules/authentication/features/presentation/bloc/auth/bloc/auth_bloc.dart';
// import 'package:attendance_system_mobile_app/modules/authentication/features/presentation/bloc/user/bloc/user_bloc.dart';
// import 'package:attendance_system_mobile_app/modules/authentication/features/presentation/providers/auth_data_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

// import '../../utils/formatted_string.dart';
// import 'loading_widget.dart';

// class NavigationDrawerWidget extends StatefulWidget {
//   const NavigationDrawerWidget({super.key});

//   @override
//   State<NavigationDrawerWidget> createState() => _NavigationDrawerWidgetState();
// }

// class _NavigationDrawerWidgetState extends State<NavigationDrawerWidget> {
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Drawer(
//         child: Align(
//           alignment: Alignment.topCenter,
//           child: Column(
//             children: [
//               BlocBuilder<AuthBloc, AuthState>(
//                 builder: (context, state) {
//                   return Container(
//                     width: double.infinity,
//                     color: Theme.of(context).colorScheme.primary,
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         SizedBox(height: 10.h),
//                         Text(
//                           sl<AuthDataProvider>().user.roleFormatted,
//                           style: TextStyle(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.bold),
//                         ),
//                         Icon(Icons.account_circle_rounded, size: 40.sp, color: Colors.white),
//                         Text(
//                           formattedName(sl<AuthDataProvider>().user.name ?? '--'),
//                           style: TextStyle(fontSize: 14.sp, color: Colors.white, fontWeight: FontWeight.bold),
//                         ),
//                         Text(
//                           sl<AuthDataProvider>().user.email ?? '--',
//                           style: TextStyle(fontSize: 12.sp, color: Colors.white),
//                         ),
//                         SizedBox(height: 10.h),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//               Flexible(
//                 child: Material(
//                   //color: Colors.grey.shade900,
//                   child: ListView(
//                     physics: const BouncingScrollPhysics(),
//                     padding: EdgeInsets.zero,
//                     children: [
//                       ListTile(
//                         leading: Icon(MdiIcons.accountEdit, color: Theme.of(context).iconTheme.color),
//                         title: const Text(
//                           "Editer le profil",
//                           //LocaleKeys.drawer_notification.tr(),
//                           style: TextStyle(),
//                         ),
//                         onTap: () {
//                           // sl<AuthController>().putCurrentProfil();
//                           // Navigator.of(context)
//                           //     .pushNamed(EditProfileScreen.routeName);
//                         },
//                       ),
//                       ListTile(
//                         leading: Icon(Icons.info, color: Theme.of(context).iconTheme.color),
//                         title: const Text(
//                           "A propos de l'app",
//                           //LocaleKeys.drawer_notification.tr(),
//                           style: TextStyle(),
//                         ),
//                         onTap: () {
//                           // Navigator.of(context).pushNamed(AboutScreen.routeName);
//                         },
//                       ),
//                       const Divider(color: Colors.grey, thickness: 1),
//                       BlocBuilder<UserBloc, UserState>(
//                         builder: (context, state) {
//                           if (state is UserLogoutLoading) {
//                             return ListTile(
//                               leading: Icon(Icons.logout, color: Theme.of(context).iconTheme.color),
//                               title: const Text(
//                                 "Se déconnecter",
//                                 //  LocaleKeys.drawer_signout.tr(),
//                                 style: TextStyle(),
//                               ),
//                               onTap: null,
//                               trailing: SizedBox(
//                                 width: 50.w,
//                                 child: const LoadingWidget(alignement: Alignment.centerRight),
//                               ),
//                             );
//                           }
//                           return ListTile(
//                             leading: Icon(Icons.logout, color: Theme.of(context).iconTheme.color),
//                             title: const Text(
//                               "Se déconnecter",
//                               //  LocaleKeys.drawer_signout.tr(),
//                               style: TextStyle(),
//                             ),
//                             onTap: () {
//                               sl<UserBloc>().add(UserLoggedout());
//                             },
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
