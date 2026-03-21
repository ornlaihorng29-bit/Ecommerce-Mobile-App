// lib/models/product_model.dart

class Product {
  final int id;
  final String name;
  final String image;       // first image URL — used in list cards
  final double price;
  final int categoryId;
  final double rate;
  final String description;
  final List<String> color;
  final bool status;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.categoryId,
    required this.rate,
    required this.description,
    required this.color,
    required this.status,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id:          json['id'] as int,
      name:        json['name'] as String,
      image:       json['image'] as String,
      price:       (json['price'] as num).toDouble(),
      categoryId:  json['categoryId'] as int,
      rate:        (json['rate'] as num).toDouble(),
      description: json['description'] as String,
      color:       List<String>.from(json['color'] as List),
      status:      json['status'] as bool,
      category:    json['category'] as String,
      createdAt:   DateTime.parse(json['createdAt'] as String),
      updatedAt:   DateTime.parse(json['updatedAt'] as String),
    );
  }
}

/// Detail model — image is a map of { filename: url }
class ProductDetail {
  final int id;
  final String name;
  final Map<String, String> images; // filename → url
  final double price;
  final int categoryId;
  final double rate;
  final String description;
  final List<String> color;
  final bool status;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductDetail({
    required this.id,
    required this.name,
    required this.images,
    required this.price,
    required this.categoryId,
    required this.rate,
    required this.description,
    required this.color,
    required this.status,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convenience: list of all image URLs
  List<String> get imageUrls => images.values.toList();

  /// First image URL for fallback
  String get firstImage => images.values.isNotEmpty
      ? images.values.first
      : '';

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    final rawImages = json['image'] as Map<String, dynamic>;
    return ProductDetail(
      id:          json['id'] as int,
      name:        json['name'] as String,
      images:      rawImages.map((k, v) => MapEntry(k, v as String)),
      price:       (json['price'] as num).toDouble(),
      categoryId:  json['categoryId'] as int,
      rate:        (json['rate'] as num).toDouble(),
      description: json['description'] as String,
      color:       List<String>.from(json['color'] as List),
      status:      json['status'] as bool,
      category:    json['category'] as String,
      createdAt:   DateTime.parse(json['createdAt'] as String),
      updatedAt:   DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class ProductMeta {
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  const ProductMeta({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  factory ProductMeta.fromJson(Map<String, dynamic> json) {
    return ProductMeta(
      currentPage: json['current_page'] as int,
      perPage:     json['per_page'] as int,
      total:       json['total'] as int,
      lastPage:    json['last_page'] as int,
    );
  }
}

class ProductListResponse {
  final List<Product> data;
  final ProductMeta meta;

  const ProductListResponse({required this.data, required this.meta});
}