import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PhysicianAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  // ignore: use_key_in_widget_constructors
  const PhysicianAppBar({
    this.height = 60,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);
  @override
  Widget build(BuildContext context) {
    return PreferredSize(
        preferredSize: Size.fromHeight(height), // here the desired height
        child: AppBar(
          // systemOverlayStyle: SystemUiOverlayStyle(
          //   statusBarColor: Theme.of(context).primaryColor,
          //   systemNavigationBarColor: Colors.transparent,
          // ),

          iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          centerTitle: true,
          title: SizedBox(
            width: 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Akili App',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 10),
                Image.asset(
                  'assets/logos/logo_ak.png',
                  fit: BoxFit.contain,
                  height: 35.h,
                  width: 35.w,
                ),
              ],
            ),
          ),
          //actions: [ComplaintIconButton()],
        ));
  }
}
