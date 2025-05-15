import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class TextFieldWidget extends StatelessWidget {
  final String hintText;
  final IconData prefixIconData;
  final IconData? suffixIconData;
  final bool obscureText;
  final Function? onChanged;
  final Function? onChangeIconstate;

  const TextFieldWidget({
    required this.hintText,
    required this.prefixIconData,
    this.suffixIconData,
    this.obscureText = false,
    this.onChanged,
    this.onChangeIconstate,
  });

  @override
  Widget build(BuildContext context) {
    //final model = Provider.of<HomeModel>(context);
    bool iconState = false;

    return TextField(
      onChanged: (value) {
        if (onChanged != null) {
          //model.searchText = value;
          onChanged!(value);
        }
        //onChanged(value);
      },

      obscureText: obscureText,
      cursorColor: Theme.of(context).primaryColor,
      // style: TextStyle(
      //   fontSize: 14.0,
      // ),

      style: GoogleFonts.montserrat(fontSize: 14),
      decoration: InputDecoration(
        labelStyle: GoogleFonts.montserrat(color: Theme.of(context).primaryColor),
        focusColor: Theme.of(context).primaryColor,
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: UnderlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(10.0.r)),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(8.0.r),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(8.0.r),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(8.0.r),
        ),
        disabledBorder: InputBorder.none,
        labelText: hintText,
        prefixIcon: Icon(
          prefixIconData,
          size: 18,
        ),
        suffixIcon: GestureDetector(
          onTap: () {
            //model.isVisible = !model.isVisible;
            iconState = !iconState;
            onChangeIconstate!(iconState);
          },
          child: suffixIconData != null ? Icon(suffixIconData, size: 18) : const SizedBox(),
        ),
      ),
    );
  }
}
