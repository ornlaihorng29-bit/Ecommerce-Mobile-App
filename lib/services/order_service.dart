// lib/services/order_service.dart

import 'package:ecommerce_mobile_app/models/order_model.dart';

import 'api_service.dart';

class OrderService {
  Future<void> placeOrder(OrderRequest request) async {
    await ApiService.post('/orders/add', request.toJson());
  }

  Future<OrderListResponse> historys({
    int page = 1,
  }) async{
      final param = <String, String>{
        'page' : '$page',
      };
      
      final response = await ApiService.get('/orders/history?page=$page&perPage=10');
      final data = (response['data'] as List).map((orderItem) => Order.fromJson(orderItem as Map<String, dynamic>)).toList();
      final meta = OrderMeta.fromJson(response['meta'] as Map<String,dynamic>);
      return OrderListResponse(data: data, meta: meta);
  }

  Future<OrderDetailResponse> historyDetails(int id) async {
    final response = await ApiService.get('/orders/history-detail/$id');
    return OrderDetailResponse.fromJson(response);
  }
}