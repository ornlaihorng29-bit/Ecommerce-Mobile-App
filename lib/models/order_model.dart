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