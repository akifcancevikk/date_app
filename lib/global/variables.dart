class LoginVariables {
  // Temporary input state for login form.
  static String? userName;
  static String? email;
  static String? password;
  static String? id;
}

class RegisterVariables {
  // Temporary input state for registration form.
  static String? name;
  static String? email;
  static String? password;
  static String? passwordConfirmation;
}

class Place{
  // Legacy place fields kept for backward compatibility.
  static String? placeId;
  static String? placeName;
  static int? placeRating = 1;
}

class Memory{
  // Temporary input state for new memory creation.
  static String? memoryName;
  static int? memoryRating = 1;
}

class MemoryUpdate{
  // Temporary input state for memory update dialog.
  static int? memoryId;
  static String? memoryName;
  static int? memoryRating = 1;
}

class PlaceDetail{
  // Legacy place detail fields kept for backward compatibility.
  static int? placeId;
  static int? orderIndex;
  static String? noteText;
  static String? imagePath;
}

class DeletePlace{
  // Legacy delete payload fields kept for backward compatibility.
  static String? id;
  static String? placeId;
  static String? imagePath;
  static String? userName;
}

class Login{
  // Current authenticated user state.
  static String? email;
  static String? userName;
  static String? userToken;
  static bool? isTokenValid;
}
