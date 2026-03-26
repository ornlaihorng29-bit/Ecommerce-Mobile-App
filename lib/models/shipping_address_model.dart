// lib/models/shipping_address_model.dart

class ShippingAddressRequestModel {
  final String address1;
  final String address2;
  final String city;
  final String state;
  final String countryCode;
  final String postalCode;

  ShippingAddressRequestModel({
    required this.address1,
    required this.address2,
    required this.city,
    required this.state,
    required this.countryCode,
    required this.postalCode,
  });

  Map<String, dynamic> toJson() => {
    "address1"    : address1,
    "address2"    : address2,
    "city"        : city,
    "stats"       : state,   // ⚠️ backend uses "stats" not "state"
    "countryCode" : countryCode,
    "postalCode"  : postalCode,
  };
}

class ShippingAddressResponseModel {
  final int id;
  final int userId;
  final String address1;
  final String address2;
  final String city;
  final String state;       // mapped from backend "stats"
  final String countryCode;
  final String postalCode;
  final DateTime createdAt;
  final DateTime updatedAt;

  ShippingAddressResponseModel({
    required this.id,
    required this.userId,
    required this.address1,
    required this.address2,
    required this.city,
    required this.state,
    required this.countryCode,
    required this.postalCode,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ShippingAddressResponseModel.fromJson(Map<String, dynamic> json) =>
      ShippingAddressResponseModel(
        id          : json['id'],
        userId      : json['userId'],
        address1    : json['address1'] ?? '',
        address2    : json['address2'] ?? '',
        city        : json['city'] ?? '',
        state       : json['stats'] ?? '',  // ⚠️ backend typo "stats"
        countryCode : json['countryCode'] ?? '',
        postalCode  : json['postalCode'] ?? '',
        createdAt   : DateTime.parse(json['createdAt']),
        updatedAt   : DateTime.parse(json['updatedAt']),
      );
}