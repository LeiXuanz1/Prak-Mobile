import 'package:my_app/utils/thumbnail_helper.dart';
import '../local/hive_boxes.dart';
import '../local/hive_models/product_hive_model.dart';
import '../cloud/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductSyncService {
  static Future<void> sync() async {
    final user = SupabaseService.client.auth.currentUser;
    final session = Supabase.instance.client.auth.currentSession;
    print('AUTH USER: ${user?.id}');
    print('SUPABASE SESSION: ${session?.user.id}');

    // Proceed with sync if Supabase client is initialized. Do not abort silently
    // when there's no authenticated user; anonymous/anon-key operations are allowed
    print('SYNC START');
    await _pushLocalToSupabase();
    await _pullSupabaseToLocal();
    print('SYNC END');
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

          await SupabaseService.client
              .from('soy_sauces')
              .delete()
              .eq('id', product.id);

          await box.delete(product.id);
          continue;
        }

        final res = await SupabaseService.client
            .from('soy_sauces')
            .upsert(product.toSupabase(), onConflict: 'id')
            .select();

        print('SUPABASE UPSERT RESULT: ${res}');

        await box.put(
          product.id,
          product.copyWith(isSynced: true, updatedAt: DateTime.now()),
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
        thumbnail: finalThumbnail,
        updatedAt: remoteUpdated,
        isSynced: true,
        source: 'supabase',
      );

      await box.put(id, merged);
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
    );
  }
}
