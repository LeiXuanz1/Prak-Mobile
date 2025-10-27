import 'package:get/get.dart';
import '../models/api_result.dart';
import '../services/http_service.dart';
import '../services/dio_service.dart';
import '../services/api_service.dart';
import '/utils/constants.dart';

class ApifyController extends GetxController {
  final ApiService _httpService = HttpService();
  final ApiService _dioService = DioService();

  final RxList<Map<String, dynamic>> logs = <Map<String, dynamic>>[].obs;
  final RxBool loading = false.obs;
  final RxString lastStatus = ''.obs;
  final RxString testMode = 'idle'.obs;

  // Stats
  final RxInt totalTests = 0.obs;
  final RxInt successCount = 0.obs;
  final RxInt errorCount = 0.obs;
  final RxDouble avgHttpTime = 0.0.obs;
  final RxDouble avgDioTime = 0.0.obs;

  // ✨ NEW: Store API data untuk ditampilkan di catalog  
  final RxList<dynamic> apiProducts = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    print('ApifyController initialized');
  }

  // ==========================================
  // ASYNC-AWAIT VERSION (Clean & Readable)
  // ==========================================
  Future<void> runComparisonAsync() async {
    loading.value = true;
    testMode.value = 'async';
    logs.clear();

    print('\n========================================');
    print('🔵 STARTING ASYNC-AWAIT TEST');
    print('========================================\n');

    try {
      // Step 1: HTTP Request dengan INPUT
      print('📤 [1/4] Fetching with HTTP (async-await) + Input...');
      final httpRes = await (_httpService as HttpService).runActorWithInput(
        AppConstants.defaultActorInput,
      );
      logs.add(_toLog('HTTP (async-await)', httpRes));
      _updateStats(httpRes, 'http');

      // 🔥 TAMBAHKAN INI: Simpan data ke apiProducts
      if (httpRes.result?.items != null && httpRes.result!.items!.isNotEmpty) {
        print('✅ HTTP: Menyimpan ${httpRes.result!.items!.length} items ke apiProducts');

        apiProducts.value = httpRes.result!.items!.map((item) {
        final categories = item['categories'];
        String category = '-';
        try {
          category = categories?[0]?['categories']?[0]?['categories']?[0]?['name'] ?? '-';
        } catch (_) {}

        final price = item['price_instructions']?['unit_price']?.toString() ?? '-';
        final stock = 15; // bisa diganti kalau dataset kamu nanti punya field stok

        return {
          'id': item['id'] ?? '-',
          'title': item['display_name'] ?? '-',
          'category': category,
          'price': price,
          'stock': stock,
          'thumbnail': item['thumbnail'],
          'status': stock > 20 ? 'Available' : 'Low Stock',
          'url': item['share_url'],
        };
      }).toList();
    } else {
        print('⚠️  HTTP: Dataset kosong');
    }

      await Future.delayed(const Duration(milliseconds: 500));

      // Step 2: DIO Request dengan INPUT
      print('📤 [2/4] Fetching with DIO (async-await) + Input...');
      final dioRes = await (_dioService as DioService).runActorWithInput(
        AppConstants.defaultActorInput,
      );
      logs.add(_toLog('DIO (async-await)', dioRes));
      _updateStats(dioRes, 'dio');

      // 🔥 TAMBAHKAN INI: Simpan data ke apiProducts (kalau HTTP gagal)
      if (dioRes.result?.items != null && dioRes.result!.items!.isNotEmpty) {
        print('✅ HTTP: Menyimpan ${dioRes.result!.items!.length} items ke apiProducts');

        apiProducts.value = dioRes.result!.items!.map((item) {
        final categories = item['categories'];
        String category = '-';
        try {
          category = categories?[0]?['categories']?[0]?['categories']?[0]?['name'] ?? '-';
        } catch (_) {}

        final price = item['price_instructions']?['unit_price']?.toString() ?? '-';
        final stock = 15; // bisa diganti kalau dataset kamu nanti punya field stok

        return {
          'id': item['id'] ?? '-',
          'title': item['display_name'] ?? '-',
          'category': category,
          'price': price,
          'stock': stock,
          'thumbnail': item['thumbnail'],
          'status': stock > 20 ? 'Available' : 'Low Stock',
          'url': item['share_url'],
        };
      }).toList();
    } else {
        print('⚠️  HTTP: Dataset kosong');
    }


      // Step 3: Chained Request (different query)
      print('🔗 [3/4] Starting chained request with different query...');
      if (httpRes.statusCode >= 200 && httpRes.statusCode < 300) {
        print('✅ First request success, trying different query...');

        final chainedInput = {'language': 'en', 'query': 'Sweet Soy Sauce'};

        await Future.delayed(const Duration(milliseconds: 300));
        final chainedRes = await (_dioService as DioService).runActorWithInput(
          chainedInput,
        );
        logs.add(_toLog('DIO (chained)', chainedRes));
        _updateStats(chainedRes, 'dio');

        // 🔥 TAMBAHKAN INI: Update apiProducts kalau ada data baru
        if (chainedRes.result?.items != null && chainedRes.result!.items!.isNotEmpty) {
          print('✅ HTTP: Menyimpan ${chainedRes.result!.items!.length} items ke apiProducts');

          apiProducts.value = chainedRes.result!.items!.map((item) {
          final categories = item['categories'];
          String category = '-';
          try {
            category = categories?[0]?['categories']?[0]?['categories']?[0]?['name'] ?? '-';
          } catch (_) {}

          final price = item['price_instructions']?['unit_price']?.toString() ?? '-';
          final stock = 15; // bisa diganti kalau dataset kamu nanti punya field stok

          return {
            'id': item['id'] ?? '-',
            'title': item['display_name'] ?? '-',
            'category': category,
            'price': price,
            'stock': stock,
            'thumbnail': item['thumbnail'],
            'status': stock > 20 ? 'Available' : 'Low Stock',
            'url': item['share_url'],
          };
        }).toList();
      } else {
        print('⚠️  HTTP: Dataset kosong');
      }


        lastStatus.value = chainedRes.result?.toString() ?? 'unknown';
        print('✅ Chained request completed: ${lastStatus.value}');
      } else {
        print('⚠️ First request failed, skipping chained request');
      }

      print('\n========================================');
      print('✅ ASYNC-AWAIT TEST COMPLETED');
      print('📦 Total items in apiProducts: ${apiProducts.length}');
      print('========================================\n');

      totalTests.value = logs.length;
    } catch (e) {
      print('❌ ERROR in async test: $e');
      errorCount.value++;
      logs.add({
        'library': 'Async Test',
        'status': 'ERROR',
        'duration': '-',
        'bytes': '-',
        'error': e.toString(),
      });
    } finally {
      loading.value = false;
      testMode.value = 'idle';
    }
  }

  // ==========================================
  // JUGA UPDATE runComparisonCallback()
  // ==========================================

  void runComparisonCallback() {
    loading.value = true;
    testMode.value = 'callback';
    logs.clear();

    print('\n========================================');
    print('🟠 STARTING CALLBACK CHAINING TEST');
    print('========================================\n');

    final url = AppConstants.apiUrl;
    final overallStopwatch = Stopwatch()..start();

    print('📤 [1/4] Fetching with HTTP (callback) + Input...');

    (_httpService as HttpService)
        .runActorWithInput(AppConstants.defaultActorInput)
        .then((httpRes) {
          logs.add(_toLog('HTTP (callback)', httpRes));
          _updateStats(httpRes, 'http');
          print('✅ HTTP callback completed');

          // 🔥 SIMPAN DATA
          if (httpRes.result?.items != null &&
              httpRes.result!.items!.isNotEmpty) {
            print('✅ HTTP: Menyimpan ${httpRes.result!.items!.length} items');
            apiProducts.value = httpRes.result!.items!;
          }

          return Future.delayed(const Duration(milliseconds: 300)).then((_) {
            print('📤 [2/4] Fetching with DIO (callback) + Input...');
            return (_dioService as DioService).runActorWithInput(
              AppConstants.defaultActorInput,
            );
          });
        })
        .then((dioRes) {
          logs.add(_toLog('DIO (callback)', dioRes));
          _updateStats(dioRes, 'dio');
          print('✅ DIO callback completed');

          // 🔥 SIMPAN DATA
          if (dioRes.result?.items != null &&
              dioRes.result!.items!.isNotEmpty) {
            print('✅ DIO: Menyimpan ${dioRes.result!.items!.length} items');
            apiProducts.value = dioRes.result!.items!;
          }

          if (dioRes.statusCode == 200 && dioRes.result != null) {
            print('🔗 [3/4] Starting chained callback...');
            return Future.delayed(const Duration(milliseconds: 200)).then((_) {
              return _httpService.fetchApifyData(url);
            });
          } else {
            print('⚠️ Skipping chained request due to error');
            throw Exception('Previous request failed');
          }
        })
        .then((chainedRes) {
          logs.add(_toLog('HTTP (chained callback)', chainedRes));
          _updateStats(chainedRes, 'http');
          lastStatus.value = chainedRes.result?.toString() ?? 'unknown';
          print('✅ Chained callback completed: ${lastStatus.value}');

          // 🔥 SIMPAN DATA
          if (chainedRes.result?.items != null &&
              chainedRes.result!.items!.isNotEmpty) {
            apiProducts.value = chainedRes.result!.items!;
          }

          overallStopwatch.stop();
          print('\n========================================');
          print('✅ CALLBACK TEST COMPLETED');
          print('⏱️  Total time: ${overallStopwatch.elapsedMilliseconds}ms');
          print('📦 Total items: ${apiProducts.length}');
          print('========================================\n');

          totalTests.value = logs.length;
        })
        .catchError((error) {
          print('❌ ERROR in callback chain: $error');
          errorCount.value++;
          logs.add({
            'library': 'Callback Chain',
            'status': 'ERROR',
            'duration': '-',
            'bytes': '-',
            'error': error.toString(),
          });
        })
        .whenComplete(() {
          loading.value = false;
          testMode.value = 'idle';
        });
  }
  // ==========================================
  // HELPER METHODS
  // ==========================================

  Map<String, dynamic> _toLog(String lib, ApiResult res) {
    return {
      'library': lib,
      'status': res.statusCode,
      'duration': '${res.durationMs} ms',
      'bytes': res.responseBytes,
      'error': res.error,
      'hasData': res.result != null,
    };
  }

  void _updateStats(ApiResult res, String type) {
    if (res.error == null) {
      successCount.value++;

      // Update average times
      if (type == 'http') {
        final current = avgHttpTime.value;
        final count = logs
            .where((l) => l['library'].toString().contains('HTTP'))
            .length;
        avgHttpTime.value = ((current * count) + res.durationMs) / (count + 1);
      } else if (type == 'dio') {
        final current = avgDioTime.value;
        final count = logs
            .where((l) => l['library'].toString().contains('DIO'))
            .length;
        avgDioTime.value = ((current * count) + res.durationMs) / (count + 1);
      }
    } else {
      errorCount.value++;
    }
  }

  void resetStats() {
    logs.clear();
    totalTests.value = 0;
    successCount.value = 0;
    errorCount.value = 0;
    avgHttpTime.value = 0.0;
    avgDioTime.value = 0.0;
    lastStatus.value = '';
    print('🔄 Stats reset');
  }

  String getSuccessRate() {
    if (totalTests.value == 0) return '0%';
    final rate = (successCount.value / totalTests.value * 100).toStringAsFixed(
      1,
    );
    return '$rate%';
  }
}
