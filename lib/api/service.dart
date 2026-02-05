// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:date_app/api/api.dart';
import 'package:date_app/global/variables.dart';
import 'package:date_app/models/memory_model.dart';
import 'package:date_app/views/login_page.dart';
import 'package:date_app/views/main_page.dart';
import 'package:date_app/provider/provider.dart';
import 'package:date_app/widgets/show_dialogs/show_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> login(BuildContext context) async {
  var response = await Api.login(LoginVariables.email!, LoginVariables.password!);
  if (response.statusCode == 200) {
    var userData = json.decode(response.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', userData['token']);
      await prefs.setString('email', userData['email']);
      Login.userToken = userData['token'];
      Login.email = userData['email'];
      Navigator.push(context,CupertinoPageRoute(builder: (context) => const MainPage()),
      );
  } else {
    var userData = json.decode(response.body);
    errorMessage(context, "${userData['message']}");
  }
}

Future<void> register(BuildContext context) async {
  var response = await Api.register(RegisterVariables.email!, RegisterVariables.password!, RegisterVariables.passwordConfirmation!, RegisterVariables.name!);
  if (response.statusCode == 200) {
    Navigator.pushAndRemoveUntil(context, CupertinoPageRoute(builder: (context) => const LoginPage(),), (route) => false,);
  } else {
    var userData = json.decode(response.body);
    errorMessage(context, "${userData['message']}");
  }
}

Future<void> checkUser(BuildContext context) async {
  var response = await Api.checkUser();
  if (response.statusCode == 200) {
    Login.isTokenValid = true;
  } else {
    Login.isTokenValid = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}

Future<void> logout(BuildContext context) async {
  var response = await Api.logout();
  if (response.statusCode == 200) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('email');
    Login.userName = null;
    Login.email = null;
    Login.userToken = null;
    Navigator.pushAndRemoveUntil(context, CupertinoPageRoute(builder: (context) => const LoginPage(),), (route) => false,);
  } else {
    var userData = json.decode(response.body);
    errorMessage(context, "${userData['message']}");
  }
}

// Future<void> getMemories(BuildContext context) async {
//   final provider = context.read<MemoryProvider>();

//   var response = await Api.getMemories();

//   if (response.statusCode == 200) {
//     final body = json.decode(response.body);

//     final List list = body['data']['data'];

//     final memories = list
//         .map((e) => MemoryModel.fromJson(e))
//         .toList();
//     provider.setPlaces(memories);

//   } else {
//     var userData = json.decode(response.body);
//     errorMessage(context, userData['message']);
//   }
// }

Future<void> fetchMemories(BuildContext context, {bool isRefresh = false}) async {
  final provider = context.read<MemoryProvider>();
  
  if (isRefresh) provider.clear();

  var response = await Api.getMemories(page: provider.currentPage);

  if (response.statusCode == 200) {
    final body = json.decode(response.body);
    final List list = body['data']['data'];
    final memories = list.map((e) => MemoryModel.fromJson(e)).toList();
    bool hasNext = body['data']['next_page_url'] != null;
    
    provider.addPlaces(memories, hasNext);
  }
}

Future<void> create(BuildContext context) async {
  var response = await Api.create(Memory.memoryName!, Memory.memoryRating!);
  if (response.statusCode >= 200 && response.statusCode < 300) {
    final body = json.decode(response.body);
    final newMemory = MemoryModel.fromJson(body['data']);
    context.read<MemoryProvider>().addSinglePlace(newMemory);
    successMessage(context, "Eklendi");
  } else {
    var userData = json.decode(response.body);
    errorMessage(context, "${userData['message']}");
  }
}

Future<void> updateMemory(BuildContext context) async {
  final response = await Api.updateMemory(
    MemoryUpdate.memoryName!,
    MemoryUpdate.memoryRating!,
    MemoryUpdate.memoryId!,
  );

  if (response.statusCode >= 200 && response.statusCode < 300) {
    final body = json.decode(response.body);
    final updatedMemory = MemoryModel.fromJson(body['data']);
    context.read<MemoryProvider>().updatePlace(updatedMemory);
  } else {
    final userData = json.decode(response.body);
    errorMessage(context, userData['message']);
  }
}

Future<void> deleteMemory(BuildContext context, int id) async {
  var response = await Api.deleteMemory(id);
  if (response.statusCode >= 200 && response.statusCode < 300) {
    context.read<MemoryProvider>().removePlaceById(id);
  } else {
    var userData = json.decode(response.body);
    errorMessage(context, "${userData['message']}");
  }
}

Future<MemoryModel?> updateNote(
  BuildContext context,
  int id,
  List<String> notes,
) async {
  final response = await Api.updateNote(id, notes);

  if (response.statusCode >= 200 && response.statusCode < 300) {
    final jsonBody = jsonDecode(response.body);
    return MemoryModel.fromJson(jsonBody['data']);
  } else {
    final userData = json.decode(response.body);
    errorMessage(context, userData['message'] ?? 'Error');
    return null;
  }
}

Future<MemoryModel?> updateImage(
  BuildContext context,
  int id,
  List<File> images,
) async {
  final streamedResponse = await Api.updateImage(id, images);

  final responseBody = await streamedResponse.stream.bytesToString();

  if (streamedResponse.statusCode >= 200 &&
      streamedResponse.statusCode < 300) {
    final jsonBody = jsonDecode(responseBody);
    return MemoryModel.fromJson(jsonBody['data']);
  } else {
    final userData = jsonDecode(responseBody);
    errorMessage(context, userData['message'] ?? 'Error');
    return null;
  }
}

Future<MemoryModel?> deleteImage(
  BuildContext context,
  int id,
  String imageName,
  List<String> notes,
) async {
  final response = await Api.deleteImage(id, imageName, notes);

  if (response.statusCode >= 200 && response.statusCode < 300) {
    final jsonBody = jsonDecode(response.body);
    return MemoryModel.fromJson(jsonBody['data']);
  } else {
    final userData = json.decode(response.body);
    errorMessage(context, userData['message'] ?? 'Error');
    return null;
  }
}
