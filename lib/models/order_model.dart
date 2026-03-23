// lib/models/order_request_model.dart

import 'dart:ffi';

import 'package:flutter/material.dart';

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

class Order {
  final int id;
  final String orderCode;
  final int userId;
  final int shippingId;
  final String paymentMethod;
  final String status;
  final String paymentStatus;
  final String promotionCode;
  final double totalAmount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Order({
    required this.id,
    required this.orderCode,
    required this.userId,
    required this.shippingId,
    required this.paymentMethod,
    required this.status,
    required this.paymentStatus,
    required this.promotionCode,
    required this.totalAmount,
    required this.createdAt,
    required this.updatedAt,
  });



  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      orderCode: json['orderCode'] as String,
      userId: json['userId'] as int,
      shippingId: json['shippingId'] as int,
      paymentMethod: json['paymentMethod'] as String,
      status: json['status'] as String,
      paymentStatus: json['paymentStatus'] as String,
      promotionCode: (json['promotionCode'] ?? '') as String,
      totalAmount: double.parse(json['totalAmount'].toString()), // ✅
      createdAt: DateTime.parse(json['createdAt'] as String),   // ✅
      updatedAt: DateTime.parse(json['updatedAt'] as String),   // ✅
    );
  }
}

class OrderMeta {
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  const OrderMeta({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  factory OrderMeta.fromJson(Map<String, dynamic> json) {
    return OrderMeta(
      currentPage: json['current_page'] as int,
      perPage: json['per_page'] as int,
      total: json['total'] as int,
      lastPage: json['last_page'] as int,
    );
  }
}

class OrderListResponse {
  final List<Order> data;
  final OrderMeta meta;
  const OrderListResponse({required this.data, required this.meta});
}


class ProductOrderItemDetail {
  final int id;
  final String name;
  final String image;
  final double price;
  final int categoryId;
  final int rate;
  final String description;
  final List<String> color;
  final bool status;           // ← JSON has true/false (bool, not String)
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductOrderItemDetail({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.categoryId,
    required this.rate,
    required this.description,
    required this.color,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  // fromJson: converts Map<String, dynamic> → ProductOrderItemDetail
  factory ProductOrderItemDetail.fromJson(Map<String, dynamic> json) {
    return ProductOrderItemDetail(
      id:           json['id'],
      name:         json['name'],
      image:        json['image'],
      price:        (json['price'] as num).toDouble(),   // num → double
      categoryId:   json['categoryId'],
      rate:         json['rate'],
      description:  json['description'],
      color:        List<String>.from(json['color']),    // JSON array → List
      status:       json['status'],
      createdAt:    DateTime.parse(json['createdAt']),   // String → DateTime
      updatedAt:    DateTime.parse(json['updatedAt']),
    );
  }
}

// ─────────────────────────────────────────────
//  2. OrderItemDetail
//     Maps each object inside the "orderItem" array
//     Contains a nested ProductOrderItemDetail
// ─────────────────────────────────────────────
class OrderItemDetail {
  final int id;
  final int orderId;
  final int productId;
  final double price;
  final int quantity;
  final double subTotal;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ProductOrderItemDetail product;   // ← nested object

  OrderItemDetail({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.price,
    required this.quantity,
    required this.subTotal,
    required this.createdAt,
    required this.updatedAt,
    required this.product,
  });

  factory OrderItemDetail.fromJson(Map<String, dynamic> json) {
    return OrderItemDetail(
      id:        json['id'],
      orderId:   json['orderId'],
      productId: json['productId'],
      price:     double.parse(json['price']),     // "10" (String) → double
      quantity:  json['quantity'],
      subTotal:  double.parse(json['subTotal']),  // "20" (String) → double
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),

      // ↓ nested: pass json['product'] into its own fromJson
      product:   ProductOrderItemDetail.fromJson(json['product']),
    );
  }
}

// ─────────────────────────────────────────────
//  3. OrderDetail
//     Maps the "data" object
//     Contains a List of OrderItemDetail
// ─────────────────────────────────────────────
class OrderDetail {
  final int id;
  final String orderCode;
  final int userId;
  final int shippingId;
  final String paymentMethod;
  final String status;
  final String paymentStatus;
  final String promotionCode;
  final double totalAmount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderItemDetail> orderItem;   // ← list of nested objects

  OrderDetail({
    required this.id,
    required this.orderCode,
    required this.userId,
    required this.shippingId,
    required this.paymentMethod,
    required this.status,
    required this.paymentStatus,
    required this.promotionCode,
    required this.totalAmount,
    required this.createdAt,
    required this.updatedAt,
    required this.orderItem,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      id:            json['id'],
      orderCode:     json['orderCode'],
      userId:        json['userId'],
      shippingId:    json['shippingId'],
      paymentMethod: json['paymentMethod'],
      status:        json['status'],
      paymentStatus: json['paymentStatus'],
      promotionCode: json['promotionCode'],
      totalAmount:   double.parse(json['totalAmount']),  // "30" → double
      createdAt:     DateTime.parse(json['createdAt']),
      updatedAt:     DateTime.parse(json['updatedAt']),

      // ↓ map each item in the array using OrderItemDetail.fromJson
      orderItem: (json['orderItem'] as List)
          .map((item) => OrderItemDetail.fromJson(item))
          .toList(),
    );
  }
}

// ─────────────────────────────────────────────
//  4. OrderDetailResponse   ← TOP LEVEL
//     Maps the full API response: { status, data }
// ─────────────────────────────────────────────
class OrderDetailResponse {
  final String status;        // "success"
  final OrderDetail data;     // the full order

  OrderDetailResponse({
    required this.status,
    required this.data,
  });

  factory OrderDetailResponse.fromJson(Map<String, dynamic> json) {
    return OrderDetailResponse(
      status: json['status'],

      // ↓ pass json['data'] into OrderDetail.fromJson
      data:   OrderDetail.fromJson(json['data']),
    );
  }
}

