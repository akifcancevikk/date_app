import 'dart:convert';
import 'package:date_app/global/variables.dart';
import 'package:date_app/helper/url_helper.dart';
import 'package:http/http.dart' as http;

class Api {

  static Future<http.Response> checkUser(String userName, String password) async {
    var url = "https://mobiledocs.aktekweb.com/api/auth/login";
    String body = json.encode({'UserName': userName, 'Password': password});
      return http.post(Uri.parse(url), headers: {"Content-Type": "application/json"}, body: body);
  }

  static Future<http.Response> register(String userName, String password) async {
    var url = "https://mobiledocs.aktekweb.com/api/auth/register";
    String body = json.encode({'UserName': userName, 'Password': password});
      return http.post(Uri.parse(url), headers: {"Content-Type": "application/json"}, body: body);
  }


static Future<http.Response> getPlaces(String userId) async {
    var url = "${Url.baseUrl}getPlaces";
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${Login.userToken}",
    };

    String body = json.encode({'UserId': userId});
    return http.post(Uri.parse(url), headers: headers, body: body);
  }


  static Future<http.Response> getPlaceDetails(String userId, String placeId) async {
    var url = "${Url.baseUrl}getPlaceDetails";
     Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${Login.userToken}",
    };
    String body = json.encode({'UserId': userId, "PlaceId": placeId});
      return http.post(Uri.parse(url), headers: headers, body: body);
  }

  static Future<http.Response> addPlace(String userId, String placeName, int rating) async {
    var url = "${Url.baseUrl}addPlace";
     Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${Login.userToken}",
    };
    String body = json.encode({'UserId': userId, "PlaceName": placeName, "rating": rating});
      return http.post(Uri.parse(url), headers: headers, body: body);
  }

  static Future<http.Response> updatePlace(String userId, String placeId, String placeName, int rating) async {
    var url = "${Url.baseUrl}updatePlace";
     Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${Login.userToken}",
    };
    String body = json.encode({'UserId': userId, "PlaceId": placeId, "PlaceName": placeName, "rating": rating});
      return http.post(Uri.parse(url), headers: headers, body: body);
  }

  static Future<http.Response> addNote(int placeId, String noteText, int orderIndex) async {
    var url = "${Url.baseUrl}addNote";
     Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${Login.userToken}",
    };
    String body = json.encode({'PlaceId': placeId, "NoteText": noteText, "OrderIndex": orderIndex});
      return http.post(Uri.parse(url), headers: headers, body: body);
  }

  static Future<http.Response> addImagePath(int placeId, String imagePath) async {
    var url = "${Url.baseUrl}addImagePath";
     Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${Login.userToken}",
    };
    String body = json.encode({'PlaceId': placeId, "ImagePath": imagePath});
      return http.post(Uri.parse(url), headers: headers, body: body);
  }

  static Future<http.Response> deletePlace(String userId, String placeId, String userName) async {
    var url = "${Url.baseUrl}deletePlace";
     Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${Login.userToken}",
    };
    String body = json.encode({'UserId': userId, "PlaceId": placeId, "UserName": userName});
      return http.post(Uri.parse(url), headers: headers, body: body);
  }

}