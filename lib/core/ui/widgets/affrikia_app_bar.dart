import 'package:dom_affrikia_app/injection_container.dart';
import 'package:dom_affrikia_app/modules/main/features/middleware/presentation/bloc/navigation/bloc/navigation_bloc.dart';
import 'package:dom_affrikia_app/modules/main/features/middleware/presentation/bloc/user/bloc/user_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AffrikiaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;

  const AffrikiaAppBar({super.key, this.height = 80});

  @override
  Size get preferredSize => Size.fromHeight(height);
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return PreferredSize(
      preferredSize: Size.fromHeight(height), // here the desired height
      child: AppBar(
        // systemOverlayStyle: SystemUiOverlayStyle(
        //   statusBarColor: Theme.of(context).primaryColor,
        //   systemNavigationBarColor: Colors.transparent,
        // ),
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        elevation: 20,
        backgroundColor: Theme.of(context).primaryColor,

        //centerTitle: true,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: size.width * 0.5,
              child: Stack(
                children: [
                  Image.asset(
                    'assets/logo/logo_w.png',
                    fit: BoxFit.contain,
                    height: 40.h,
                  ),
                  Positioned(
                    bottom: 0,
                    left: 50,
                    child: Text(
                      'Device Manager',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Row(
            //   children: [
            //     Icon(Icons.person_outline_rounded),
            //   ],
            // )
            IconButton(
                onPressed: () {
                  sl<UserBloc>().add(UserLoggedOut());
                },
                icon: Icon(
                  Icons.exit_to_app,
                  color: Colors.white,
                ))
          ],
        ),
        // actions: [
        //   Icon(
        //     Icons.person_outline_rounded,
        //     color: Colors.white,
        //   )
        // ],
      ),
    );
  }
}
