class MemoryModel {
  final int id;
  final int userId;
  final String title;
  final int rating;
  final List<String> paths; // Yeni eklendi
  final List<String> notes; // Yeni eklendi
  final DateTime createdAt;
  final DateTime updatedAt;

  MemoryModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.rating,
    required this.paths,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MemoryModel.fromJson(Map<String, dynamic> json) {
    return MemoryModel(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'] ?? "",
      rating: json['rating'] ?? 0,
      // API'den null gelirse veya boş gelirse boş liste döndürür
      paths: json['paths'] != null ? List<String>.from(json['paths']) : [],
      notes: json['notes'] != null ? List<String>.from(json['notes']) : [],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}