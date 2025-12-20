import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

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
    await testConnection();

    log(dotenv.env['SUPABASE_URL'] ?? '');
    log(dotenv.env['SUPABASE_ANON_KEY']?.substring(0, 10) ?? '');
  }

  // Quick test
  static Future<void> testConnection() async {
    try {
      final res = await client.from('soy_sauces').select().limit(1);
      log('Supabase connected. Sample response: $res');
    } catch (e, stack) {
      log('Supabase connection failed', error: e, stackTrace: stack);
    }
  }

  static bool get isAuthenticated =>
      client.auth.currentSession?.user.role == 'authenticated';

  static Future<Map<String, dynamic>> insertSoySauce(
    Map<String, dynamic> row,
  ) async {
    if (!isAuthenticated) {
      log('User not authenticated');
    }

    final res = await client.from('soy_sauces').insert(row).select().single();

    return Map<String, dynamic>.from(res);
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
