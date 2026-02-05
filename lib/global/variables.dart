class LoginVariables {
  static String? userName;
  static String? email;
  static String? password;
  static String? id;
}

class RegisterVariables {
  static String? name;
  static String? email;
  static String? password;
  static String? passwordConfirmation;
}

class Place{
  static String? placeId;
  static String? placeName;
  static int? placeRating = 1;
}

class Memory{
  static String? memoryName;
  static int? memoryRating = 1;
}

class MemoryUpdate{
  static int? memoryId;
  static String? memoryName;
  static int? memoryRating = 1;
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
  static String? imagePath;
  static String? userName;
}

class Login{
  static String? email;
  static String? userName;
  static String? userToken;
  static bool? isTokenValid;
}