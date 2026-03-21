// lib/services/profile_service.dart

import 'package:image_picker/image_picker.dart';
import '../models/profile_model.dart';
import 'api_service.dart';

class ProfileService {
  /// GET /users/profile
  Future<UserProfile> getProfile() async {
    final response = await ApiService.get('/users/profile');
    return UserProfile.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// POST /users/edit — JSON fields
  Future<void> editProfile(EditProfileRequest request) async {
    await ApiService.patch('/users/edit', request.toJson());
  }

  /// POST /users/edit — FormData with image only (web-safe)
 Future<void> uploadImageWithProfile(
      XFile file, EditProfileRequest request) async {
    await ApiService.uploadXFile(
      endpoint:  '/users/edit',
      fieldName: 'image',
      file:      file,
      method:    'POST',
      fields:    request.toStringMap(), // ← all profile fields as form fields
    );
  }
}