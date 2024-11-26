// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'dart:convert';

import 'package:date_app/api/api.dart';
import 'package:date_app/global/lists.dart';
import 'package:date_app/global/variables.dart';
import 'package:date_app/helper/url_helper.dart';
import 'package:date_app/models/place_detail.dart';
import 'package:date_app/models/places.dart';
import 'package:date_app/views/main_page.dart';
import 'package:date_app/widgets/show_dialogs/show_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> checkUser(BuildContext context) async {
  try {
    var response = await Api.checkUser(User.userName!, User.password!);
    if (response.statusCode == 200) {
      var userData = json.decode(response.body);
      if (userData['status'] == 0) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userName', User.userName!);
        await prefs.setString('password', User.password!);
        User.id = userData['id'].toString();
        Login.userName = userData['name'];
        Url.imgUrl = "https://mobiledocs.aktekweb.com/places/${Login.userName}/"; // Burada güncelle
        await getPlaces();
        Navigator.push(
          context,
          CupertinoPageRoute(builder: (context) => MainPage()),
        );
      } else {
        errorMessage(context, "${userData['message']}");
      }
    } else {
      errorMessage(context, 'İstek sırasında bir hata oluştu.');
    }
  } catch (error) {
    if(User.password == null)
    {
      errorMessage(context, 'Şifre boş bırakıldı.');
    }
    else {
      errorMessage(context, 'İnternet bağlantısı bulunamadı.');
    }
  }
}


Future<void> register(BuildContext context) async {
  try {
    var response = await Api.register(RegisterUser.userName!, RegisterUser.password!);
    if (response.statusCode == 200) {
      var userData = json.decode(response.body);
      if (userData['status'] == 0) {
        User.userName = RegisterUser.userName;
        User.password = RegisterUser.password;
        await checkUser(context);
      } else {
        errorMessage(context, "${userData['message']}");
      }
    } else {
      errorMessage(context, 'Böyle bir kullanıcı kayıtlı. Farklı bir ad deneyin');
    }
  } catch (error) {
      errorMessage(context, "$error");

  }
}

Future<void> getPlaces() async {
  var userId = User.id;
  await Api.getPlaces(userId!).then((response) {
    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      GlobalLists.places = list.map((e) => Places.fromJson(e)).toList();
    }
  });
}

Future<void> getPlaceDetails() async {
  var userId = User.id;
  var placeId = Place.placeId;
  await Api.getPlaceDetails(userId!, placeId!).then((response) {
    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      GlobalLists.placesDetail = list.map((e) => PlaceDetails.fromJson(e)).toList();
    }
  });
}

Future<void> addPlace(BuildContext context) async {
  var userId = User.id;
  var placeName = Place.placeName;
  var rating = Place.placeRating;
  await Api.addPlace(userId!, placeName!, rating!).then((response) {
    if (response.statusCode == 200) {
      successMessage(context, "Yer Eklendi");
      Place.placeName = null;
      Place.placeRating = 1;
    }
  });
}

Future<void> updatePlace(BuildContext context) async {
  var userId = User.id;
  var placeName = PlaceUpdate.placeName;
  var placeId = PlaceUpdate.placeId;
  var rating = PlaceUpdate.placeRating;
  await Api.updatePlace(userId!, placeId!, placeName!, rating!).then((response) {
    if (response.statusCode == 200) {
      successMessage(context, "Güncellendi");
      PlaceUpdate.placeName = null;
      PlaceUpdate.placeRating = 1;
      PlaceUpdate.placeId=null;
    }
  });
}

Future<void> addNote(BuildContext context) async {
  var placeId = PlaceDetail.placeId;
  var noteText = PlaceDetail.noteText;
  var orderIndex = PlaceDetail.orderIndex;
  await Api.addNote(placeId!, noteText!, orderIndex!).then((response) {
    if (response.statusCode == 200) {
      successMessage(context, "Not Eklendi");
      PlaceDetail.placeId = null;
      PlaceDetail.noteText = null;
      PlaceDetail.orderIndex = null;
    }
  });
}

Future<void> addImagePath(BuildContext context) async {
  var placeId = PlaceDetail.placeId;
  var imagePath = PlaceDetail.imagePath;
  await Api.addImagePath(placeId!, imagePath!).then((response) {
    if (response.statusCode == 200) {
      successMessage(context, "Resim Eklendi");
      PlaceDetail.placeId = null;
      PlaceDetail.imagePath = null;
    }
  });
}

Future<void> deletePlace(BuildContext context) async {
  var userId = DeletePlace.id;
  var placeId = DeletePlace.placeId;
  var userName = Login.userName;
  await Api.deletePlace(userId!, placeId!, userName!).then((response) {
    if (response.statusCode == 200) {
      successMessage(context, "Kayıt Silindi");
    }
  });
}