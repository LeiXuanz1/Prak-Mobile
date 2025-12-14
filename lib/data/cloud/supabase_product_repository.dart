import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseProductRepository {
  final SupabaseClient client = Supabase.instance.client;

  // Insert product
  Future<void> addProduct(Map<String, dynamic> json) async {
    try {
      await client.from('products').insert(json);
    } catch (e) {
      rethrow;
    }
  }

  // Get all products
  Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      final data = await client.from('products').select();
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      rethrow;
    }
  }

  // Update product
  Future<void> updateProduct(String id, Map<String, dynamic> json) async {
    try {
      await client.from('products').update(json).eq('id', id);
    } catch (e) {
      rethrow;
    }
  }

  // Delete product
  Future<void> deleteProduct(String id) async {
    try {
      await client.from('products').delete().eq('id', id);
    } catch (e) {
      rethrow;
    }
  }
}