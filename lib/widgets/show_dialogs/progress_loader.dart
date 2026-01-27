// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

Future<dynamic> progress_loader(BuildContext context) {
  return showDialog(
  barrierColor: Colors.black,
  context: context,
  barrierDismissible: false,
  builder: (BuildContext context) {
    return Center(
      child: Image.asset(
        'assets/images/progress.gif',
        width: 100,
        height: 100,
      ),
    );
  },
 );
}