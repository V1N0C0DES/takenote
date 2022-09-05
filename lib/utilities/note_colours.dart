import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

class NoteColor {
  static Color getColor(int code) {
    switch (code) {
      case 0:
        return FlexColor.blueWhaleDarkPrimary.lighten(20);
      case 1:
        return FlexColor.sakuraLightSecondary.lighten(15);

      case 2:
        return FlexColor.greenDarkPrimary.lighten(10);

      case 3:
        return FlexColor.blueLightPrimary.lighten(40);
      case 4:
        return FlexColor.sakuraLightPrimary.lighten(10);
      case 5:
        return FlexColor.indigoLightSecondary.lighten(40);
      default:
        return Colors.transparent;
    }
  }

  static int getCode(Color color) {
    if (color == Colors.transparent) {
      return 0;
    } else if (color == const Color(0xFFFCECDD)) {
      return 1;
    } else if (color == const Color(0xffE4FBFF)) {
      return 2;
    } else if (color == const Color(0xffB6C9F0)) {
      return 3;
    } else if (color == const Color(0xffFFE8E8)) {
      return 4;
    } else if (color == const Color(0xffE1CCEC)) {
      return 5;
    } else {
      return 0;
    }
  }
}
