// lib/services/product_service.dart

import '../models/product_model.dart';
import 'api_service.dart';

class ProductService {
  /// GET /products/client-view?page=1&categoryId=2
  Future<ProductListResponse> getProducts({
    int page = 1,
    int? categoryId,
    String? name,
    double? priceMin,
    double? priceMax,
  }) async {
    final params = <String, String>{
      'page': '$page',
      if (categoryId != null) 'categoryId': '$categoryId',
      if (name != null && name.isNotEmpty) 'name': name,
      if (priceMin != null) 'priceMin': '$priceMin',
      if (priceMax != null) 'priceMax': '$priceMax',
    };

    final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    final response = await ApiService.get('/products/client-view?$query');

    final data = (response['data'] as List)
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();
    final meta = ProductMeta.fromJson(response['meta'] as Map<String, dynamic>);
    return ProductListResponse(data: data, meta: meta);
  }


  /// GET /products/detail/:id
  Future<ProductDetail> getProductDetail(int id) async {
    final response = await ApiService.get('/products/client-detail/$id');
    return ProductDetail.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<ProductClientHomeViewResponse> getProductClientHomeView() async {
    final response = await ApiService.get('/products/client-product-home-view');
    final data = (response['data'] as List)
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();
    return ProductClientHomeViewResponse(data: data);
  }
}
