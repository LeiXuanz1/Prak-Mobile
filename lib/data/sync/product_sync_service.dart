import 'dart:io';
import 'package:my_app/utils/thumbnail_helper.dart';
import '../local/hive_boxes.dart';
import '../local/hive_models/product_hive_model.dart';
import '../cloud/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductSyncService {
  static bool _isSyncing = false;

  static Future<void> sync() async {
    final SupabaseClient client = Supabase.instance.client;
    final Session? session = client.auth.currentSession;

    if (session == null) {
      print('SYNC Skipped - session not ready');
      return;
    }

    if (_isSyncing) {
      print('SYNCING SKIPPED: already syncing');
      return;
    }

    _isSyncing = true;

    try {
      print('SYNC START user = ${session.user.id}');
      await _pushLocalToSupabase();
      await _pullSupabaseToLocal();
      print('SYNC END');
    } catch (e, s) {
      print('SYNC ERROR');
      print(e);
      print(s);
    } finally {
      _isSyncing = false;
    }
  }

  static bool isUuid(String v) => RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(v);

  // PUSH LOCAL → SUPABASE
  static Future<void> _pushLocalToSupabase() async {
    final box = HiveBoxes.products;

    print('TOTAL LOCAL: ${box.length}');

    final dirtyProducts = box.values.where((p) => !p.isSynced).toList();
    print('DIRTY COUNT: ${dirtyProducts.length}');

    if (dirtyProducts.isEmpty) return;

    for (final product in dirtyProducts) {
      print('➡️ PUSHING ID=${product.id}, deleted=${product.isDeleted}');
      try {
        if (product.isDeleted) {
          if (!isUuid(product.id)) {
            print('LOCAL-ONLY DELETE (legacy id) ${product.id}');
            await box.delete(product.id);
            continue;
          }

          final res = await SupabaseService.client
              .from('soy_sauces')
              .delete()
              .eq('id', product.id)
              .select();

          print('SUPABASE DELETE RESULT: $res');

          await box.delete(product.id);
          continue;
        }

        final uploadedThumbnail = await _uploadLocalThumbnailIdNeeded(
          product.thumbnail,
        );

        final res = await SupabaseService.client
            .from('soy_sauces')
            .upsert(
              product.copyWith(thumbnail: uploadedThumbnail).toSupabase(),
              onConflict: 'id',
            )
            .select();

        print('SUPABASE UPSERT RESULT: ${res}');

        await box.put(
          product.id,
          product.copyWith(
            thumbnail: uploadedThumbnail,
            isSynced: true,
            updatedAt: DateTime.now(),
          ),
        );
      } catch (e, stack) {
        print('SUPABASE ERROR FOR ${product.id}');
        print(e);
        print(stack);
      }
    }
  }

  // PULL SUPABASE → LOCAL
  static Future<void> _pullSupabaseToLocal() async {
    final box = HiveBoxes.products;

    final remote = await SupabaseService.client.from('soy_sauces').select();

    for (final map in remote) {
      final id = map['id']?.toString();
      if (id == null) continue;

      final remoteUpdatedRaw = map['updated_at'];
      if (remoteUpdatedRaw == null) continue;

      final remoteUpdated = DateTime.parse(remoteUpdatedRaw);
      final local = box.get(id);

      if (local != null && local.isDeleted) {
        continue;
      }

      if (local == null) {
        await box.put(id, _fromSupabase(map));
        continue;
      }

      if (!remoteUpdated.isAfter(local.updatedAt)) continue;

      final String? remoteThumbnail = ThumbnailHelper.normalize(
        map['thumbnail'],
      );

      final String? localThumb = local.thumbnail;
      final bool isLocalPath = localThumb != null && localThumb.startsWith('/');

      String? finalThumbnail;

      if (isLocalPath) {
        finalThumbnail = localThumb;
      } else if (remoteThumbnail != null && remoteThumbnail.isNotEmpty) {
        finalThumbnail = remoteThumbnail;
      } else {
        finalThumbnail = localThumb;
      }

      final merged = local.copyWith(
        title: map['display_name'] ?? local.title,
        category: map['category'] ?? local.category,
        price: (map['price'] as num?)?.toDouble() ?? local.price,
        unit: map['unit_size']?.toString() ?? local.unit,
        description: map['description'] ?? local.description,
        packaging: map['packaging'] ?? local.packaging,
        thumbnail: finalThumbnail,
        updatedAt: remoteUpdated,
        isSynced: true,
        source: 'supabase',
      );

      await box.put(id, merged.copyWith(source: 'supabase'));
    }
  }

  // Mapper Supabase → Hive
  static ProductHiveModel _fromSupabase(Map<String, dynamic> map) {
    return ProductHiveModel(
      id: map['id'].toString(),
      title: map['display_name'] ?? '',
      category: map['category'] ?? '',
      stock: map['stock'] ?? 0,
      unit: map['unit_size']?.toString() ?? '',
      price: (map['price'] as num).toDouble(),
      description: '',
      thumbnail: ThumbnailHelper.normalize(map['thumbnail']),
      source: 'supabase',
      status: 'active',
      updatedAt: DateTime.parse(map['updated_at']),
      isSynced: true,
      packaging: map['packaging'] ?? '',
    );
  }

  static Future<String?> _uploadLocalThumbnailIdNeeded(
    dynamic thumbnail,
  ) async {
    if (thumbnail == null) return null;

    final raw = thumbnail.toString().trim();

    if (raw.startsWith('soy_sauces/') || raw.startsWith('http')) {
      return raw;
    }

    if (!raw.startsWith('/')) return null;

    final file = File(raw);
    if (!file.existsSync()) return null;

    final ext = raw.split('.').last;
    final name = '${DateTime.now().millisecondsSinceEpoch}.$ext';
    final storagePath = 'soy_sauces/$name';

    final bytes = await file.readAsBytes();

    await SupabaseService.client.storage
        .from('kecap-images')
        .uploadBinary(storagePath, bytes);

    return storagePath;
  }
}
