import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();

  /// Helper: hex stringből Color
  static Color fromHex(String hexString) {
   final buffer = StringBuffer();
   if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
   buffer.write(hexString.replaceFirst('#', ''));
   return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Méretezett TextStyle
  static TextStyle scaledTextStyle(
      BuildContext context, {
       double fontSize = 14,
       FontWeight fontWeight = FontWeight.normal,
       Color? color,
       String? hexColor,
      }) {
   final scale = MediaQuery.of(context).textScaleFactor;
   return TextStyle(
    fontSize: fontSize * scale,
    fontWeight: fontWeight,
    color: hexColor != null ? fromHex(hexColor) : color ?? Colors.black,
   );
  }

  /// Példák előre definiált stílusokra
  static TextStyle actionSheetItem(BuildContext context, {Color? color, String? hexColor}) =>
      scaledTextStyle(
       context,
       fontSize: 18,
       color: color,
       hexColor: hexColor ?? "007AFF",
      );

  static TextStyle headline4(BuildContext context, {Color? color, String? textColor}) =>
      scaledTextStyle(
       context,
       fontSize: 20,
        color: color,
       fontWeight: FontWeight.w700,
       hexColor: textColor,
      );
}
