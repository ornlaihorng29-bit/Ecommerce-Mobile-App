// lib/models/cart_item.dart

class CartItem {
  final int productId;
  final String name;
  final double price;
  final String? imageUrl;       // ← add this
  final String? selectedColor;  // ← add this
  int quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    this.imageUrl,
    this.selectedColor,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'name': name,
        'price': price,
        'imageUrl': imageUrl,
        'selectedColor': selectedColor,
        'quantity': quantity,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        productId: json['productId'],
        name: json['name'],
        price: (json['price'] as num).toDouble(),
        imageUrl: json['imageUrl'],
        selectedColor: json['selectedColor'],
        quantity: json['quantity'],
      );
}