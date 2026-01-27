class PlaceDetails {
  int userId;
  String userName;
  int placeId;
  String placeName;
  DateTime visitDate;
  int rating;
  List<String> images;
  List<String> notes;

  PlaceDetails({
    required this.userId,
    required this.userName,
    required this.placeId,
    required this.placeName,
    required this.visitDate,
    required this.rating,
    required this.images,
    required this.notes,
  });

  // JSON'dan PlaceDetails nesnesi oluşturma
  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    return PlaceDetails(
      userId: json['userId'],
      userName: json['userName'],
      placeId: json['placeId'],
      placeName: json['placeName'],
      visitDate: DateTime.parse(json['visitDate']),
      rating: json['rating'],
      images: List<String>.from(json['images']),
      notes: List<String>.from(json['notes']),
    );
  }

  // PlaceDetails nesnesini JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'placeId': placeId,
      'placeName': placeName,
      'visitDate': visitDate.toIso8601String(),
      'rating': rating,
      'images': images,
      'notes': notes,
    };
  }
}
