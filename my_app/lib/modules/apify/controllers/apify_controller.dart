import 'package:get/get.dart';

// Models
import '../models/api_result.dart';
import '../models/apify_result.dart';

// Services
import '../../../data/remote/http_service.dart';
import '../../../data/remote/dio_service.dart';
import '../../../data/remote/api_service.dart';
import '../../../core/constants/api_constants.dart';

// Hive
import '/data/local/hive_boxes.dart';

// Supabase
import '../../../data/cloud/supabase_service.dart';
import 'package:my_app/data/cloud/supabase_product_repository.dart';

class ApifyController extends GetxController {
  // --- Services
  final ApiService _httpService = HttpService();
  final ApiService _dioService = DioService();
  final SupabaseProductRepository supabaseRepo = SupabaseProductRepository();

  // --- Observable state (UI-referenced)
  final RxList<Map<String, dynamic>> apiProducts = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> productsSupabase =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> recentActivities =
      <Map<String, dynamic>>[].obs;

  // logs / benchmarking
  final RxList<Map<String, dynamic>> logs = <Map<String, dynamic>>[].obs;
  final RxBool loading = false.obs;
  final RxString lastStatus = ''.obs;
  final RxString testMode = 'idle'.obs;

  final RxInt totalTests = 0.obs;
  final RxInt successCount = 0.obs;
  final RxInt errorCount = 0.obs;
  final RxDouble avgHttpTime = 0.0.obs;
  final RxDouble avgDioTime = 0.0.obs;

  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();

    loadSupabaseProducts();
    _loadApiProductsFromHive();
    _loadRecentActivitiesFromHive();
  }

  // HIVE LOAD & SAVE
  void _loadApiProductsFromHive() {
    final raw = HiveBoxes.apiProducts.get('items', defaultValue: []);
    final list = (raw as List).map<Map<String, dynamic>>((e) {
      return Map<String, dynamic>.from(e as Map);
    }).toList();
    apiProducts.assignAll(list);
  }

  void _saveApiProductsToHive() {
    HiveBoxes.apiProducts.put('items', apiProducts.toList());
    HiveBoxes.apiProducts.flush();
  }

  void _loadRecentActivitiesFromHive() {
    final raw = HiveBoxes.recentActivities.get('items', defaultValue: []);
    final list = (raw as List).map<Map<String, dynamic>>((e) {
      return Map<String, dynamic>.from(e as Map);
    }).toList();
    recentActivities.assignAll(list);
  }

  void _saveRecentActivitiesToHive() {
    HiveBoxes.recentActivities.put('items', recentActivities.toList());
    HiveBoxes.recentActivities.flush();
  }


  // SUPABASE LOAD (READ ONLY)
  Future<void> loadSupabaseProducts() async {
    try {
      final data = await SupabaseService.getSoySauces();
      productsSupabase.assignAll(data);
    } catch (e) {
      _logError('supabase', e);
    }
  }

  // CRUD LOCAL PRODUCT LIST + SAVE TO HIVE
  void addProduct(Map<String, dynamic> product, {bool toTop = true}) {
    if (toTop) {
      apiProducts.insert(0, product);
    } else {
      apiProducts.add(product);
    }

    _saveApiProductsToHive();

    recentActivities.insert(0, {
      'type': 'add',
      'title': product['title'] ?? product['display_name'] ?? '-',
      'description': 'Product added',
      'timeAgo': 'just now',
      'timestamp': DateTime.now().toIso8601String(),
    });

    _saveRecentActivitiesToHive();
  }

  void updateProductStock(String id, int newStock) {
    final index = apiProducts.indexWhere((p) => p['id'] == id);
    if (index == -1) return;

    apiProducts[index]['stock'] = newStock;
    apiProducts[index]['status'] = newStock > 20 ? 'Available' : 'Low Stock';

    _saveApiProductsToHive();

    recentActivities.insert(0, {
      'type': 'update',
      'title': apiProducts[index]['title'] ?? '-',
      'description': 'Stock updated to $newStock',
      'timeAgo': 'just now',
      'timestamp': DateTime.now().toIso8601String(),
    });

    _saveRecentActivitiesToHive();
  }

  void deleteProduct(String id) {
    final removed = apiProducts.firstWhereOrNull((p) => p['id'] == id);
    apiProducts.removeWhere((p) => p['id'] == id);

    _saveApiProductsToHive();

    if (removed != null) {
      recentActivities.insert(0, {
        'type': 'delete',
        'title': removed['title'] ?? '-',
        'description': 'Product removed',
        'timeAgo': 'just now',
        'timestamp': DateTime.now().toIso8601String(),
      });
    }

    _saveRecentActivitiesToHive();
  }

  // API RESULT HELPERS
  ApifyResult? _tryGetApifyResult(ApiResult res) {
    final result = res.result;
    if (result == null) return null;

    if (result.items.isEmpty) return null;

    return result;
  }

  List<Map<String, dynamic>> _mapItems(List<dynamic> items) {
    return items.map<Map<String, dynamic>>((item) {
      // category
      String category = '-';
      try {
        category =
            item['categories']?[0]?['categories']?[0]?['categories']?[0]?['name'] ??
                '-';
      } catch (_) {}

      // price
      String priceStr = '-';
      try {
        final up = item['price_instructions']?['unit_price'];
        if (up != null) priceStr = up.toString();
      } catch (_) {}

      return <String, dynamic>{
        'id': item['id'] ?? '-',
        'title': item['display_name'] ?? item['title'] ?? '-',
        'category': category,
        'price': priceStr,
        'stock': 15,
        'thumbnail': item['thumbnail'],
        'status': 15 > 20 ? 'Available' : 'Low Stock',
        'url': item['share_url'],
      };
    }).toList();
  }

  // LOGGING & STATS
  Map<String, dynamic> _toLog(String lib, ApiResult res) {
    return {
      'library': lib,
      'status': res.statusCode,
      'duration': '${res.durationMs} ms',
      'bytes': res.responseBytes,
      'error': res.error,
      'hasData': _tryGetApifyResult(res) != null,
    };
  }

  void _logError(String source, dynamic error) {
    errorCount.value++;
    logs.add({
      'library': source,
      'status': 'ERROR',
      'duration': '-',
      'bytes': '-',
      'error': error.toString(),
    });
  }

  void _updateStats(ApiResult res, String type) {
    if (res.error == null) {
      successCount.value++;

      final current = (type == 'http') ? avgHttpTime.value : avgDioTime.value;

      final count = logs.where((l) =>
              l['library']?.toString().toLowerCase().contains(type) ??
              false)
          .length;

      final avg =
          ((current * (count - 1).clamp(0, double.infinity)) + res.durationMs) /
              (count.clamp(1, double.infinity));

      if (type == 'http') {
        avgHttpTime.value = avg;
      } else {
        avgDioTime.value = avg;
      }
    } else {
      errorCount.value++;
    }
  }

  // ASYNC TEST
  Future<void> runComparisonAsync() async {
    loading.value = true;
    testMode.value = 'async';
    logs.clear();

    try {
      // HTTP
      final httpRes = await (_httpService as HttpService).runActorWithInput(
        AppConstants.defaultActorInput,
      );
      logs.add(_toLog('HTTP (async-await)', httpRes));
      _updateStats(httpRes, 'http');

      final httpData = _tryGetApifyResult(httpRes);
      if (httpData != null) {
        apiProducts.value = _mapItems(httpData.items);
        _saveApiProductsToHive();
      }

      await Future.delayed(const Duration(milliseconds: 400));

      // DIO
      final dioRes = await (_dioService as DioService).runActorWithInput(
        AppConstants.defaultActorInput,
      );
      logs.add(_toLog('DIO (async-await)', dioRes));
      _updateStats(dioRes, 'dio');

      final dioData = _tryGetApifyResult(dioRes);
      if (dioData != null) {
        apiProducts.value = _mapItems(dioData.items);
        _saveApiProductsToHive();
      }

      // Chained
      if (httpRes.statusCode == 200) {
        final chainedRes = await _dioService.runActorWithInput({
          'language': 'en',
          'query': 'Sweet Soy Sauce',
        });

        logs.add(_toLog('DIO (chained)', chainedRes));
        _updateStats(chainedRes, 'dio');

        final chainedData = _tryGetApifyResult(chainedRes);
        if (chainedData != null) {
          apiProducts.value = _mapItems(chainedData.items);
          _saveApiProductsToHive();
        }
      }

      totalTests.value = logs.length;
    } catch (e) {
      _logError('Async Test', e);
    } finally {
      loading.value = false;
      testMode.value = 'idle';
    }
  }

  // CALLBACK
  void runComparisonCallback() {
    loading.value = true;
    testMode.value = 'callback';
    logs.clear();

    (_httpService as HttpService)
        .runActorWithInput(AppConstants.defaultActorInput)
        .then((httpRes) {
      logs.add(_toLog('HTTP (callback)', httpRes));
      _updateStats(httpRes, 'http');

      final data = _tryGetApifyResult(httpRes);
      if (data != null) {
        apiProducts.value = _mapItems(data.items);
        _saveApiProductsToHive();
      }

      return (_dioService as DioService).runActorWithInput(
        AppConstants.defaultActorInput,
      );
    }).then((dioRes) {
      logs.add(_toLog('DIO (callback)', dioRes));
      _updateStats(dioRes, 'dio');

      final data = _tryGetApifyResult(dioRes);
      if (data != null) {
        apiProducts.value = _mapItems(data.items);
        _saveApiProductsToHive();
      }

      return _httpService.fetchApifyData(AppConstants.apiUrl);
    }).then((chainedRes) {
      logs.add(_toLog('HTTP (chained callback)', chainedRes));
      _updateStats(chainedRes, 'http');

      final data = _tryGetApifyResult(chainedRes);
      if (data != null) {
        apiProducts.value = _mapItems(data.items);
        _saveApiProductsToHive();
      }

      totalTests.value = logs.length;
    }).catchError((error) {
      _logError('Callback Chain', error);
    }).whenComplete(() {
      loading.value = false;
      testMode.value = 'idle';
    });
  }

  // UTILITIES
  void resetStats() {
    logs.clear();
    totalTests.value = 0;
    successCount.value = 0;
    errorCount.value = 0;
    avgHttpTime.value = 0.0;
    avgDioTime.value = 0.0;
    lastStatus.value = '';
  }

  String getSuccessRate() {
    if (totalTests.value == 0) return '0%';
    final rate =
        (successCount.value / totalTests.value * 100).toStringAsFixed(1);
    return '$rate%';
  }
}