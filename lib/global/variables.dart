class User {
  static String? userName;
  static String? password;
  static String? id;
}

class Place{
  static String? placeId;
  static String? placeName;
  static int? placeRating = 1;
}

class PlaceUpdate{
  static String? placeId;
  static String? placeName;
  static int? placeRating = 1;
}

class PlaceDetail{
  static int? placeId;
  static int? orderIndex;
  static String? noteText;
  static String? imagePath;
}

class DeletePlace{
  static String? id;
  static String? placeId;
}