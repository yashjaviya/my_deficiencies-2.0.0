import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_deficiencies/color/app_color.dart';

extension Spacing on double {
  Widget get hs => SizedBox(height: this);
}

extension Spacing1 on double {
  Widget get ws => SizedBox(width: this);
}

Widget appText({String? title, FontWeight? fontWeight, double? fontSize, double? letterSpacing, TextDecoration? decoration, Color? color, Color? decorationColor, double? height, int? maxLines, FontStyle? fontStyle, TextOverflow? overflow, TextAlign? textAlign}) {
  return Text(
    title.toString(),
    textAlign: textAlign,
    overflow: overflow,
    maxLines: maxLines,
    style: TextStyle(
      height: height,
      fontWeight: fontWeight,
      fontSize: fontSize,
      fontFamily: 'gelasio',
      letterSpacing: letterSpacing,
      color: color,
      fontStyle: fontStyle,
      decorationColor: decorationColor,
      decoration: decoration,
    ),
  );
}

void flutterToastTop(String errorMessage) {
  Fluttertoast.showToast(msg: errorMessage, toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.TOP, timeInSecForIosWeb: 1, backgroundColor: Colors.red, textColor: Colors.white, fontSize: 16.0);
}

void flutterToastCenter(String errorMessage) {
  Fluttertoast.showToast(msg: errorMessage, toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.CENTER, timeInSecForIosWeb: 1, backgroundColor: Colors.red, textColor: Colors.white, fontSize: 16.0);
}

void flutterToastBottom(errorMessage) {
  Fluttertoast.showToast(
    msg: errorMessage,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.CENTER,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.white60,
    textColor: Colors.black,
    fontSize: 16.0,
  );
}

void flutterToastBottomGreen(errorMessage) {
  Fluttertoast.showToast(
    msg: errorMessage,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 2,
    backgroundColor: Colors.green,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}

Widget appTextField({String? hintText, String? errorText, EdgeInsets? margin, TextInputType? textInputType, Widget? prefixIcon, Widget? suffixIcon, TextEditingController? controller, bool obscureText = false}) {
  return Container(
    margin: margin,
    height: 64,
    alignment: Alignment.center,
    child: TextFormField(
      controller: controller,
      keyboardType: textInputType,
      obscureText: obscureText,
      validator: (value) {
        return errorText;
      },
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        filled: true,
        fillColor: AppColor.btnColor.withValues(alpha: 0.5),
        isDense: true,
        hintText: hintText,
        hintStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          fontFamily: 'gelasio',
          color: AppColor.c959DAE,
        ),
        alignLabelWithHint: true
      ),
      style: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 16,
        fontFamily: 'gelasio',
        color: AppColor.white,
      ),
    ),
  );
}