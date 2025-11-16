// supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseService {
  // client akan di-set setelah Supabase.initialize dipanggil
  static late final SupabaseClient client;

  /// Inisialisasi Supabase (panggil sekali di start aplikasi)
  static Future<void> init() async {
    // Pastikan .env sudah diload di main sebelum memanggil ini
    final url = dotenv.env['SUPABASE_URL'];
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (url == null || anonKey == null) {
      throw Exception(
          'SUPABASE_URL atau SUPABASE_ANON_KEY tidak ditemukan di .env');
    }

    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );

    // ambil client global yang sudah di-create oleh Supabase.initialize
    client = Supabase.instance.client;

    // jalankan quick test koneksi (opsional)
    await testConnection();
  }

  /// Quick test: select 1 row dari table 'soy_sauces' (atau tabel lain)
  static Future<void> testConnection() async {
    try {
      final res = await client.from('soy_sauces').select().limit(1);
      // res bisa berupa List<dynamic> jika sukses
      print('🔥 Supabase OK — koneksi bekerja');
      print(res);
    } catch (e, st) {
      print('❌ Supabase ERROR saat testConnection(): $e');
      print(st);
    }
  }

  /// Contoh helper: insert data ke table
  static Future<void> insertSoySauce(Map<String, dynamic> row) async {
    try {
      await client.from('soy_sauces').insert(row);
    } catch (e) {
      rethrow;
    }
  }

  /// Ambil semua soy_sauces
  static Future<List<Map<String, dynamic>>> getSoySauces() async {
    try {
      final data = await client.from('soy_sauces').select();
      return List<Map<String, dynamic>>.from(data as List);
    } catch (e) {
      rethrow;
    }
  }
}
