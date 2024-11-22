import 'package:flutter/material.dart';

class ScreenHelper {
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double screenHeightPercentage(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.height * percentage / 100;
  }

  static double screenWidthPercentage(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * percentage / 100;
  }
}