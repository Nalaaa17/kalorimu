import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _bucketName = 'food-images';

  Future<String?> uploadFoodImage(File imageFile, String userId) async {
    try {
      final fileName = '${const Uuid().v4()}.jpg';
      final filePath = '$userId/$fileName';

      // Upload file to Supabase Storage
      await _supabase.storage.from(_bucketName).upload(
            filePath,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      // Get public URL
      final publicUrl =
          _supabase.storage.from(_bucketName).getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  Future<void> deleteFoodImage(String imageUrl) async {
    try {
      // Extract file path from URL (naive approach, assume it's in food-images bucket)
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      
      // Find the index of 'food-images' in the path
      final bucketIndex = pathSegments.indexOf(_bucketName);
      if (bucketIndex != -1 && pathSegments.length > bucketIndex + 1) {
        // Construct the file path within the bucket
        final filePath = pathSegments.sublist(bucketIndex + 1).join('/');
        await _supabase.storage.from(_bucketName).remove([filePath]);
      }
    } catch (e) {
      debugPrint('Error deleting image: $e');
    }
  }
}
