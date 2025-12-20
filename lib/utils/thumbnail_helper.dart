import '../data/cloud/supabase_service.dart';

class ThumbnailHelper {
  static String? normalize(dynamic raw) {
    if (raw == null) return null;

    final s = raw.toString().trim();
    if (s.isEmpty) return null;

    // Sudah URL
    if (s.startsWith('http')) return s;

    // Path Supabase Storage → Public URL
    final clean = s.replaceAll(RegExp(r'^/+'), '');

    return SupabaseService.client.storage
        .from('kecap-images')
        .getPublicUrl(clean);
  }
}
