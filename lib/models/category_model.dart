// lib/models/category_model.dart

class Category {
  final int id;
  final String name;
  final String image;
  final bool status;
  final DateTime createdAt;

  const Category({
    required this.id,
    required this.name,
    required this.image,
    required this.status,
    required this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id:        json['id'] as int,
      name:      json['name'] as String,
      image:     json['image'] as String,
      status:    json['status'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}