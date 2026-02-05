import 'dart:convert';
import 'dart:io';
import 'package:date_app/global/variables.dart';
import 'package:date_app/helper/device_helper.dart';
import 'package:date_app/helper/url_helper.dart';
import 'package:http/http.dart' as http;

class Api {

  static Future<http.Response> login(String email, String password) async {
    final deviceName = await DeviceHelper.getDeviceName();

    var url = "${Url.memories}auth/login";
    String body = json.encode({
      'email': email,
      'password': password,
      'device_name': deviceName,
    });

    return http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: body,
    );
  }

  static Future<http.Response> register(String email, String password, String passwordConfirmation, String name) async {
    var url = "${Url.memories}auth/register";
    String body = json.encode({
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'name': name,
    });

    return http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: body,
    );
  }

  static Future<http.Response> checkUser() async {
    var url = "${Url.memories}user";
    return http.get(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer ${Login.userToken}",
      },
    );
  }

  static Future<http.Response> logout() async {
    var url = "${Url.memories}auth/logout";
    return http.delete(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer ${Login.userToken}",
      },
    );
  }

  static Future<http.Response> getMemories({int page = 1}) async {
    var url = "${Url.memories}memories?page=$page";
    return http.get(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer ${Login.userToken}",
      },
    );
  }

  static Future<http.Response> create(String title, int rating) async {
    var url = "${Url.memories}memories";
    String body = json.encode({
      'title': title,
      'rating': rating,
    });

    return http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer ${Login.userToken}",
      },
      body: body,
    );
  }

  static Future<http.Response> updateMemory(String title, int rating, int id) async {
    var url = "${Url.memories}memories/$id";
    String body = json.encode({
      'title': title,
      'rating': rating,
    });

    return http.patch(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer ${Login.userToken}",
      },
      body: body,
    );
  }

  static Future<http.Response> deleteMemory(int id) async {
    var url = "${Url.memories}memories/$id";
    return http.delete(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer ${Login.userToken}",
      },
    );
  }

  static Future<http.Response> updateNote(
    int id,
    List<String> notes,
  ) async {
    final url = "${Url.memories}memories/$id/notes";

    return http.put(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer ${Login.userToken}",
      },
      body: jsonEncode({
        "notes": notes,
      }),
    );
  }

  static Future<http.StreamedResponse> updateImage(
    int id,
    List<File> images,
  ) async {
    final url = "${Url.memories}memories/$id/image";

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(url),
    );

    request.headers.addAll({
      "Accept": "application/json",
      "Authorization": "Bearer ${Login.userToken}",
    });

    for (final file in images) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'images[]', // 🔥 backend field name
          file.path,
        ),
      );
    }

    return request.send();
  }

  static Future<http.Response> deleteImage(
    int id,
    String imageName,
    List<String> notes,
  ) async {
    final url = "${Url.memories}memories/$id/image/$imageName";

    return http.delete(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer ${Login.userToken}",
      },
      body: jsonEncode({
        "notes": notes,
      }),
    );
  }

}
