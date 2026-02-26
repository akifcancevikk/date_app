import 'package:flutter/material.dart';

class ScreenHelper {
  // Return full screen width.
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  // Return full screen height.
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  // Return height by percentage of screen.
  static double screenHeightPercentage(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.height * percentage / 100;
  }

  // Return width by percentage of screen.
  static double screenWidthPercentage(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * percentage / 100;
  }
}
