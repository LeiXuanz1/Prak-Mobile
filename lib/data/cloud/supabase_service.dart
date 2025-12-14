import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseService {
  static late final SupabaseClient client;

  // Inisialisasi Supabase
  static Future<void> init() async {
    final url = dotenv.env['SUPABASE_URL'];
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (url == null || anonKey == null) {
      throw Exception(
        'SUPABASE_URL atau SUPABASE_ANON_KEY tidak ditemukan di .env',
      );
    }

    await Supabase.initialize(url: url, anonKey: anonKey);

    client = Supabase.instance.client;
    await testConnection();
  }

  // Quick test
  static Future<void> testConnection() async {
    try {
      final res = await client.from('soy_sauces').select().limit(1);
      log('Supabase connected. Sample response: $res');
    } catch (e, stack) {
      log('Supabase connection failed', error: e, stackTrace: stack,);
    }
  }

  static Future<void> insertSoySauce(Map<String, dynamic> row) async {
    try {
      await client.from('soy_sauces').insert(row);
    } catch (e, stack) {
      log('Failed to insert soy sauce', error: e, stackTrace: stack,);
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getSoySauces() async {
    try {
      final data = await client.from('soy_sauces').select();
      return List<Map<String, dynamic>>.from(data as List);
    } catch (e) {
      rethrow;
    }
  }
}
