// lib/utils/image_url.dart
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

String resolveImageUrl(String originalUrl) {
  // Only proxy on web builds — native has no CORS restriction
  if (kIsWeb) {
    final encoded = Uri.encodeComponent(originalUrl);
    return '${ApiService.baseUrl}/proxy/image?url=$encoded';
  }
  return originalUrl;
}