import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

MaterialColor colorCustom = MaterialColor(0Xd42e12, color);

Map<int, Color> color = const {
  50: Color.fromRGBO(252, 174, 8, .1),
  100: Color.fromRGBO(252, 174, 8, .2),
  200: Color.fromRGBO(252, 174, 8, .3),
  300: Color.fromRGBO(252, 174, 8, .4),
  400: Color.fromRGBO(252, 174, 8, .5),
  500: Color.fromRGBO(252, 174, 8, .6),
  600: Color.fromRGBO(252, 174, 8, .7),
  700: Color.fromRGBO(252, 174, 8, .8),
  800: Color.fromRGBO(252, 174, 8, .9),
  900: Color.fromRGBO(252, 174, 8, 1),
};

class AppThemes {
  AppThemes(this.isCurrentThemeModeDark);

  bool isCurrentThemeModeDark;
  static final darkTheme = ThemeData(
    scaffoldBackgroundColor: Colors.grey.shade900,
    brightness: Brightness.dark,
    primaryColor: const Color.fromRGBO(252, 174, 8, 1),
    primarySwatch: colorCustom,
    primaryColorLight: const Color.fromRGBO(252, 174, 8, .9),
    colorScheme: ColorScheme.dark(
      primary: colorCustom.shade900,
      secondary: colorCustom.shade900,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
    ),
    // unselectedWidgetColor: Colors,
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.montserrat(fontSize: 30.sp),
      headlineMedium: GoogleFonts.montserrat(fontSize: 23.sp),
      headlineSmall: GoogleFonts.montserrat(fontSize: 22.sp),
      displayLarge: GoogleFonts.montserrat(fontSize: 22.sp),

      titleMedium: GoogleFonts.montserrat(
        fontSize: 14.sp,
        // color: const Color.fromRGBO(250, 46, 18, 1),
        // fontWeight: FontWeight.bold,
      ),

      bodyMedium: GoogleFonts.montserrat(fontSize: 14.sp),
      bodySmall: GoogleFonts.montserrat(fontSize: 12.sp),
      labelMedium: GoogleFonts.montserrat(fontSize: 10.sp),
      // button: GoogleFonts.montserrat(
      //   fontSize: 14.sp,
      //   fontWeight: FontWeight.w700,
      // ),
      // labelSmall: GoogleFonts.montserrat(fontSize: 10.sp, color: Colors.white),
    ),

    // toggleableActiveColor: colorCustom.shade900,
    // iconTheme: IconThemeData(color: Colors.white, size: 24.w),
    // primaryIconTheme: const IconThemeData(color: Colors.white),

    // checkboxTheme: CheckboxThemeData(
    //   checkColor: MaterialStateProperty.all(Colors.green),
    // ),
    sliderTheme: SliderThemeData(
      //showValueIndicator: ,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
      thumbColor: colorCustom.shade900,
      trackHeight: 6,
      //trackShape: ,
      valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
      tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 5),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: Colors.grey.shade900,
      // shape: RoundedRectangleBorder(
      //   borderRadius: BorderRadius.only(
      //     topLeft: Radius.circular(20.r),
      //     topRight: Radius.circular(20.r),
      //   ),
      // ),
    ),
  );
  static final lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.grey.shade100,
    brightness: Brightness.light,
    primaryColor: const Color.fromRGBO(252, 174, 8, 1),
    primarySwatch: colorCustom,
    primaryColorLight: const Color.fromRGBO(252, 174, 8, .9),
    colorScheme: ColorScheme.light(primary: colorCustom.shade900, secondary: colorCustom.shade900),
    cardColor: Colors.grey.shade200,
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.montserrat(fontSize: 30.sp),
      headlineMedium: GoogleFonts.montserrat(fontSize: 23.sp, fontWeight: FontWeight.bold, color: Colors.black),
      headlineSmall: GoogleFonts.montserrat(fontSize: 22.sp),
      // headline4: GoogleFonts.montserrat(
      //   fontSize: 22.sp,
      // ),
      titleLarge: GoogleFonts.montserrat(fontSize: 20.sp, color: Colors.white, fontWeight: FontWeight.bold),
      titleMedium: GoogleFonts.montserrat(
        fontSize: 14.sp,
        // fontWeight: FontWeight.bold,
        // color: const Color.fromRGBO(250, 46, 18, 1),
      ),

      bodyMedium: GoogleFonts.montserrat(fontSize: 14.sp),

      bodySmall: GoogleFonts.montserrat(fontSize: 12.sp),
      // subtitle1: GoogleFonts.montserrat(
      //   fontSize: 12.sp,
      // ),
      // subtitle2: GoogleFonts.montserrat(
      //   fontSize: 12.sp,
      // ),
      // bodyText1: GoogleFonts.montserrat(
      //   fontSize: 14.sp,
      // ),
      // bodyText2: GoogleFonts.montserrat(
      //   fontSize: 12.sp,
      // ),
      // caption: GoogleFonts.montserrat(
      //   fontSize: 10.sp,
      // ),
      // button: GoogleFonts.montserrat(
      //   fontSize: 14.sp,
      //   fontWeight: FontWeight.w700,
      // ),
      // overline: GoogleFonts.montserrat(
      //   fontSize: 10.sp,
      //   color: Colors.black,
      // ),

      // headline1: GoogleFonts.montserrat(
      //   fontSize: 30.sp,
      // ),
      // headline2: GoogleFonts.montserrat(
      //   fontSize: 23.sp,
      //   fontWeight: FontWeight.bold,
      //   color: Colors.black,
      // ),
      // headline3: GoogleFonts.montserrat(
      //   fontSize: 22.sp,
      // ),
      // headline4: GoogleFonts.montserrat(
      //   fontSize: 22.sp,
      // ),
      // headline5: GoogleFonts.montserrat(
      //   fontSize: 20.sp,
      //   color: Colors.white,
      //   fontWeight: FontWeight.bold,
      // ),
      // headline6: GoogleFonts.montserrat(
      //   fontSize: 16.sp,
      //   fontWeight: FontWeight.bold,
      //   color: const Color.fromRGBO(250, 46, 18, 1),
      // ),
      // subtitle1: GoogleFonts.montserrat(
      //   fontSize: 12.sp,
      // ),
      // subtitle2: GoogleFonts.montserrat(
      //   fontSize: 12.sp,
      // ),
      // bodyText1: GoogleFonts.montserrat(
      //   fontSize: 14.sp,
      // ),
      // bodyText2: GoogleFonts.montserrat(
      //   fontSize: 12.sp,
      // ),
      // caption: GoogleFonts.montserrat(
      //   fontSize: 10.sp,
      // ),
      // button: GoogleFonts.montserrat(
      //   fontSize: 14.sp,
      //   fontWeight: FontWeight.w700,
      // ),
      // overline: GoogleFonts.montserrat(
      //   fontSize: 10.sp,
      //   color: Colors.black,
      // ),
    ),
    iconTheme: IconThemeData(color: Colors.black, size: 24.w),

    sliderTheme: SliderThemeData(
      //showValueIndicator: ,
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0.r),
      thumbColor: colorCustom.shade900,
      trackHeight: 6,
      //trackShape: ,
      valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
      tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 5),
    ),
    //buttonTheme: ButtonTheme(shape: ,)
  );

  static bool isBrightnessDark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;
  static bool isBrightnessLight(BuildContext context) => Theme.of(context).brightness == Brightness.light;
}

// Custom widget styles
class CustomButtonStyles {
  static final ButtonStyle primaryBoldElevatedButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.white,

    // onPrimary: Colors.white,
    // primary: colorCustom,
    padding: const EdgeInsets.symmetric(horizontal: 48),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(2))),
  );
}
