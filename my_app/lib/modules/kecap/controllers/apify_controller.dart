import 'package:get/get.dart';
import '../models/api_result.dart';
import '../services/http_service.dart';
import '../services/dio_service.dart';
import '../services/api_service.dart';
import '/utils/constants.dart';

// SUPABASE
import '../services/supabase_service.dart';
import 'package:my_app/data/cloud/supabase_product_repository.dart';

class ApifyController extends GetxController {
  // SERVICES
  final ApiService _httpService = HttpService();
  final ApiService _dioService = DioService();
  final SupabaseProductRepository supabaseRepo = SupabaseProductRepository();

  // DATA APIFY (HTTP & DIO)
  final RxList<Map<String, dynamic>> apiProducts = <Map<String, dynamic>>[].obs;

  // DATA SUPABASE
  final RxList<Map<String, dynamic>> productsSupabase = <Map<String, dynamic>>[].obs;

  // SEARCH
  final RxString searchQuery = ''.obs;

  // ACTIVITY LOG
  final RxList<Map<String, dynamic>> recentActivities = <Map<String, dynamic>>[].obs;

  // TEST LOGS + BENCHMARKS
  final RxList<Map<String, dynamic>> logs = <Map<String, dynamic>>[].obs;
  final RxBool loading = false.obs;
  final RxString lastStatus = ''.obs;
  final RxString testMode = 'idle'.obs;

  final RxInt totalTests = 0.obs;
  final RxInt successCount = 0.obs;
  final RxInt errorCount = 0.obs;
  final RxDouble avgHttpTime = 0.0.obs;
  final RxDouble avgDioTime = 0.0.obs;

  // ===========================
  // INIT
  // ===========================
  @override
  void onInit() {
    super.onInit();
    loadSupabaseProducts();
    print('ApifyController initialized ✅');
  }

  // ===========================
  // SUPABASE LOAD
  // ===========================
  Future<void> loadSupabaseProducts() async {
    try {
      final data = await SupabaseService.getSoySauces();
      productsSupabase.assignAll(data);
      print("Supabase data loaded: ${data.length}");
    } catch (e) {
      print("❌ Failed to load Supabase products: $e");
    }
  }

  // ===========================
  // CRUD: LOCAL PRODUCT LIST
  // ===========================
  void addProduct(Map<String, dynamic> product, {bool toTop = true}) {
    if (toTop) {
      apiProducts.insert(0, product);
    } else {
      apiProducts.add(product);
    }

    recentActivities.insert(0, {
      'type': 'add',
      'title': product['title'],
      'timestamp': DateTime.now().toString(),
    });
  }

  void updateProductStock(String id, int newStock) {
    final index = apiProducts.indexWhere((p) => p['id'] == id);
    if (index != -1) {
      apiProducts[index]['stock'] = newStock;
      apiProducts[index]['status'] = newStock > 20 ? 'Available' : 'Low Stock';

      recentActivities.insert(0, {
        'type': 'update',
        'id': id,
        'stock': newStock,
        'timestamp': DateTime.now().toString(),
      });
    }
  }

  void deleteProduct(String id) {
    apiProducts.removeWhere((p) => p['id'] == id);

    recentActivities.insert(0, {
      'type': 'delete',
      'id': id,
      'timestamp': DateTime.now().toString(),
    });
  }

  // ===========================
  // ASYNC-AWAIT TEST
  // ===========================
  Future<void> runComparisonAsync() async {
    loading.value = true;
    testMode.value = 'async';
    logs.clear();

    print('\n===== STARTING ASYNC TEST =====\n');

    try {
      // HTTP TEST
      final httpRes = await (_httpService as HttpService)
          .runActorWithInput(AppConstants.defaultActorInput);

      logs.add(_toLog('HTTP (async-await)', httpRes));
      _updateStats(httpRes, 'http');

      if (_hasData(httpRes)) {
        apiProducts.value = _mapItems(httpRes.result!.items!);
      }

      await Future.delayed(const Duration(milliseconds: 400));

      // DIO TEST
      final dioRes = await (_dioService as DioService)
          .runActorWithInput(AppConstants.defaultActorInput);

      logs.add(_toLog('DIO (async-await)', dioRes));
      _updateStats(dioRes, 'dio');

      if (_hasData(dioRes)) {
        apiProducts.value = _mapItems(dioRes.result!.items!);
      }

      // CHAINED DIO
      if (httpRes.statusCode == 200) {
        final chainedRes = await (_dioService as DioService).runActorWithInput({
          'language': 'en',
          'query': 'Sweet Soy Sauce',
        });

        logs.add(_toLog('DIO (chained)', chainedRes));
        _updateStats(chainedRes, 'dio');
      }

      totalTests.value = logs.length;
    } catch (e) {
      print('❌ ERROR in async test: $e');
      _logError('Async Test', e);
    } finally {
      loading.value = false;
      testMode.value = 'idle';
    }
  }

  // ===========================
  // CALLBACK VERSION
  // ===========================
  void runComparisonCallback() {
    loading.value = true;
    testMode.value = 'callback';
    logs.clear();

    print('\n===== STARTING CALLBACK TEST =====\n');

    (_httpService as HttpService)
        .runActorWithInput(AppConstants.defaultActorInput)
        .then((httpRes) {
          logs.add(_toLog('HTTP (callback)', httpRes));
          _updateStats(httpRes, 'http');

          if (_hasData(httpRes)) {
            apiProducts.value = _mapItems(httpRes.result!.items!);
          }

          return (_dioService as DioService)
              .runActorWithInput(AppConstants.defaultActorInput);
        })
        .then((dioRes) {
          logs.add(_toLog('DIO (callback)', dioRes));
          _updateStats(dioRes, 'dio');

          if (_hasData(dioRes)) {
            apiProducts.value = _mapItems(dioRes.result!.items!);
          }

          return (_httpService as HttpService).fetchApifyData(
            AppConstants.apiUrl,
          );
        })
        .then((chainedRes) {
          logs.add(_toLog('HTTP (chained callback)', chainedRes));
          _updateStats(chainedRes, 'http');

          if (_hasData(chainedRes)) {
            apiProducts.value = _mapItems(chainedRes.result!.items!);
          }

          totalTests.value = logs.length;
        })
        .catchError((error) {
          print('❌ ERROR in callback chain: $error');
          _logError('Callback Chain', error);
        })
        .whenComplete(() {
          loading.value = false;
          testMode.value = 'idle';
        });
  }

  // ===========================
  // HELPERS
  // ===========================
  bool _hasData(ApiResult res) =>
      res.result?.items != null && res.result!.items!.isNotEmpty;

  List<Map<String, dynamic>> _mapItems(List<dynamic> items) {
    return items.map((item) {
      String category = "-";

      try {
        category =
            item['categories']?[0]?['categories']?[0]?['categories']?[0]
                    ['name'] ??
                '-';
      } catch (_) {}

      return {
        'id': item['id'] ?? '-',
        'title': item['display_name'] ?? '-',
        'category': category,
        'price':
            item['price_instructions']?['unit_price']?.toString() ?? '-',
        'stock': 15,
        'thumbnail': item['thumbnail'],
        'status': 15 > 20 ? 'Available' : 'Low Stock',
        'url': item['share_url'],
      };
    }).toList();
  }

  Map<String, dynamic> _toLog(String lib, ApiResult res) {
    return {
      'library': lib,
      'status': res.statusCode,
      'duration': '${res.durationMs} ms',
      'bytes': res.responseBytes,
      'error': res.error,
      'hasData': _hasData(res),
    };
  }

  void _updateStats(ApiResult res, String type) {
    if (res.error == null) {
      successCount.value++;
      final current =
          type == 'http' ? avgHttpTime.value : avgDioTime.value;

      final count = logs
          .where((l) => l['library'].toString().contains(type.toUpperCase()))
          .length;

      final avg = ((current * count) + res.durationMs) / (count + 1);

      if (type == 'http') avgHttpTime.value = avg;
      if (type == 'dio') avgDioTime.value = avg;
    } else {
      errorCount.value++;
    }
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

  // RESET ALL METRICS
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