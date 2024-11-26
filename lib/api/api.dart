import 'dart:convert';
import 'package:date_app/helper/url_helper.dart';
import 'package:http/http.dart' as http;

class Api {

  static Future<http.Response> checkUser(String userName, String password) async {
    var url = "${Url.baseUrl}checkUser";
    String body = json.encode({'UserName': userName, 'Password': password});
      return http.post(Uri.parse(url), headers: {"Content-Type": "application/json"}, body: body);
  }

  static Future<http.Response> register(String userName, String password) async {
    var url = "${Url.baseUrl}register";
    String body = json.encode({'UserName': userName, 'Password': password});
      return http.post(Uri.parse(url), headers: {"Content-Type": "application/json"}, body: body);
  }

  static Future<http.Response> getPlaces(String userId) async {
    var url = "${Url.baseUrl}getPlaces";
    String body = json.encode({'UserId': userId});
      return http.post(Uri.parse(url), headers: {"Content-Type": "application/json"}, body: body);
  }

  static Future<http.Response> getPlaceDetails(String userId, String placeId) async {
    var url = "${Url.baseUrl}getPlaceDetails";
    String body = json.encode({'UserId': userId, "PlaceId": placeId});
      return http.post(Uri.parse(url), headers: {"Content-Type": "application/json"}, body: body);
  }

  static Future<http.Response> addPlace(String userId, String placeName, int rating) async {
    var url = "${Url.baseUrl}addPlace";
    String body = json.encode({'UserId': userId, "PlaceName": placeName, "rating": rating});
      return http.post(Uri.parse(url), headers: {"Content-Type": "application/json"}, body: body);
  }

  static Future<http.Response> updatePlace(String userId, String placeId, String placeName, int rating) async {
    var url = "${Url.baseUrl}updatePlace";
    String body = json.encode({'UserId': userId, "PlaceId": placeId, "PlaceName": placeName, "rating": rating});
      return http.post(Uri.parse(url), headers: {"Content-Type": "application/json"}, body: body);
  }

  static Future<http.Response> addNote(int placeId, String noteText, int orderIndex) async {
    var url = "${Url.baseUrl}addNote";
    String body = json.encode({'PlaceId': placeId, "NoteText": noteText, "OrderIndex": orderIndex});
      return http.post(Uri.parse(url), headers: {"Content-Type": "application/json"}, body: body);
  }

   static Future<http.Response> addImagePath(int placeId, String imagePath) async {
    var url = "${Url.baseUrl}addImagePath";
    String body = json.encode({'PlaceId': placeId, "ImagePath": imagePath});
      return http.post(Uri.parse(url), headers: {"Content-Type": "application/json"}, body: body);
  }

  static Future<http.Response> deletePlace(String userId, String placeId, String userName) async {
    var url = "${Url.baseUrl}deletePlace";
    String body = json.encode({'UserId': userId, "PlaceId": placeId, "UserName": userName});
      return http.post(Uri.parse(url), headers: {"Content-Type": "application/json"}, body: body);
  }


}