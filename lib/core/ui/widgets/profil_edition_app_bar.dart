import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ProfilEditionAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  // ignore: use_key_in_widget_constructors
  const ProfilEditionAppBar({
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

          title: Text(
            "Edition du profil",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(MdiIcons.accountEdit),
            )
          ],
        ));
  }
}
