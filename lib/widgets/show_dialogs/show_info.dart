// ignore_for_file: file_names, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:awesome_top_snackbar/awesome_top_snackbar.dart';
import 'package:flutter/material.dart';


// Show a warning snackbar at the top of the screen.
warningMessage(BuildContext context, String text){
  return awesomeTopSnackbar(
    context,
    text,
    backgroundColor: Colors.blue.shade400,
    icon: const Icon(Icons.info, color: Colors.white),
    iconWithDecoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white),
    ),
  );
}


// Show an error snackbar at the top of the screen.
errorMessage(BuildContext context, String text){
  return awesomeTopSnackbar(
    context, 
    text,
    backgroundColor: Colors.red.shade600,
    icon: const Icon(Icons.close, color: Colors.white),
    iconWithDecoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white),
    ),
  );
}


// Show a success snackbar at the top of the screen.
successMessage(BuildContext context, String text){
  return awesomeTopSnackbar(
    context, 
    text,
    backgroundColor: Colors.green.shade800,
    icon: const Icon(Icons.check, color: Colors.white),
    iconWithDecoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white),
    ),
  );
}




