class Places {
  int userId;
  String userName;
  int placeId;
  String placeName;
  String visitDate;
  int rating;
  String imagePath;
  String noteText;
  int orderIndex;

  Places({
    required this.userId,
    required this.userName,
    required this.placeId,
    required this.placeName,
    required this.visitDate,
    required this.rating,
    required this.imagePath,
    required this.noteText,
    required this.orderIndex,
  });

  // JSON'dan Visit nesnesi oluşturma
  factory Places.fromJson(Map<String, dynamic> json) {
    return Places(
      userId: json['userId'],
      userName: json['userName'],
      placeId: json['placeId'],
      placeName: json['placeName'],
      visitDate: json['visitDate'],
      rating: json['rating'],
      imagePath: json['imagePath'],
      noteText: json['noteText'],
      orderIndex: json['orderIndex'],
    );
  }

  // Visit nesnesini JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'placeId': placeId,
      'placeName': placeName,
      'visitDate': visitDate,
      'rating': rating,
      'imagePath': imagePath,
      'noteText': noteText,
      'orderIndex': orderIndex,
    };
  }
}
