// lib/services/order_service.dart

import 'package:ecommerce_mobile_app/models/order_model.dart';

import 'api_service.dart';

class OrderService {
  Future<void> placeOrder(OrderRequest request) async {
    await ApiService.post('/orders/add', request.toJson());
  }
}