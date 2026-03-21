// lib/models/order_request_model.dart

class OrderItem {
  final int productId;
  final int quantity;

  OrderItem({required this.productId, required this.quantity});

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'quantity': quantity,
      };
}

class OrderRequest {
  final String paymentMethod;
  final String promotionCode;
  final List<OrderItem> orderItems;

  OrderRequest({
    required this.paymentMethod,
    this.promotionCode = '',
    required this.orderItems,
  });

  // Matches your API payload exactly
  Map<String, dynamic> toJson() => {
        'paymentMethod': paymentMethod,
        'promotionCode': promotionCode,
        'order_items': orderItems.map((e) => e.toJson()).toList(),
      };
}