// lib/services/shipping_address_service.dart

import 'package:ecommerce_mobile_app/models/shipping_address_model.dart';
import 'package:ecommerce_mobile_app/services/api_service.dart';

class ShippingAddressService {

  /// Fetch current user's shipping address
  /// Returns null if no address exists yet
  Future<ShippingAddressResponseModel?> getMyAddress() async {
    try {
      final response = await ApiService.get('/shippings/detail');
      final data = response['data'];
      if (data == null) return null;
      return ShippingAddressResponseModel.fromJson(data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Create new shipping address
  Future<void> store(ShippingAddressRequestModel request) async {
    await ApiService.post('/shippings/add', request.toJson());
  }

  /// Update existing shipping address
  Future<void> update(ShippingAddressRequestModel request) async {
    await ApiService.put('/shippings/edit', request.toJson());
  }
}