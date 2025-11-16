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

  // ✨ Data untuk UI
  final RxList<Map<String, dynamic>> apiProducts = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    print('ApifyController initialized ✅');
  }

  // ASYNC-AWAIT VERSION
  Future<void> runComparisonAsync() async {
    loading.value = true;
    testMode.value = 'async';
    logs.clear();

    print('\n========================================');
    print('🔵 STARTING ASYNC-AWAIT TEST');
    print('========================================\n');

    try {
      // Step 1: HTTP Request
      print('📤 [1/4] Fetching with HTTP (async-await) + Input...');
      final httpRes = await (_httpService as HttpService).runActorWithInput(
        AppConstants.defaultActorInput,
      );
      logs.add(_toLog('HTTP (async-await)', httpRes));
      _updateStats(httpRes, 'http');

      if (_hasData(httpRes)) {
        apiProducts.value = _mapItems(httpRes.result!.items!);
        print('✅ HTTP: ${apiProducts.length} items disimpan');
      } else {
        print('⚠️ HTTP dataset kosong');
      }

      await Future.delayed(const Duration(milliseconds: 500));

      // Step 2: DIO Request
      print('📤 [2/4] Fetching with DIO (async-await) + Input...');
      final dioRes = await (_dioService as DioService).runActorWithInput(
        AppConstants.defaultActorInput,
      );
      logs.add(_toLog('DIO (async-await)', dioRes));
      _updateStats(dioRes, 'dio');

      if (_hasData(dioRes)) {
        apiProducts.value = _mapItems(dioRes.result!.items!);
        print('✅ DIO: ${apiProducts.length} items disimpan');
      } else {
        print('⚠️ DIO dataset kosong');
      }

      // Step 3: Chained Request
      print('🔗 [3/4] Starting chained request with different query...');
      if (httpRes.statusCode == 200) {
        final chainedInput = {'language': 'en', 'query': 'Sweet Soy Sauce'};
        await Future.delayed(const Duration(milliseconds: 300));
        final chainedRes =
            await (_dioService as DioService).runActorWithInput(chainedInput);
        logs.add(_toLog('DIO (chained)', chainedRes));
        _updateStats(chainedRes, 'dio');

        if (_hasData(chainedRes)) {
          apiProducts.value = _mapItems(chainedRes.result!.items!);
          print('✅ Chained: ${apiProducts.length} items disimpan');
        } else {
          print('⚠️ Chained dataset kosong');
        }

        lastStatus.value = 'Chained OK';
      } else {
        print('⚠️ First request failed, skipping chained request');
      }

      print('\n========================================');
      print('✅ ASYNC-AWAIT TEST COMPLETED');
      print('📦 Total items: ${apiProducts.length}');
      print('========================================\n');

      totalTests.value = logs.length;
    } catch (e) {
      print('❌ ERROR in async test: $e');
      _logError('Async Test', e);
    } finally {
      loading.value = false;
      testMode.value = 'idle';
    }
  }

  // CALLBACK VERSION
  void runComparisonCallback() {
    loading.value = true;
    testMode.value = 'callback';
    logs.clear();

    print('\n========================================');
    print('🟠 STARTING CALLBACK CHAINING TEST');
    print('========================================\n');

    final url = AppConstants.apiUrl;
    final stopwatch = Stopwatch()..start();

    (_httpService as HttpService)
        .runActorWithInput(AppConstants.defaultActorInput)
        .then((httpRes) {
          logs.add(_toLog('HTTP (callback)', httpRes));
          _updateStats(httpRes, 'http');
          print('✅ HTTP callback completed');

          if (_hasData(httpRes)) {
            apiProducts.value = _mapItems(httpRes.result!.items!);
            print('✅ HTTP: ${apiProducts.length} items disimpan');
          } else {
            print('⚠️ HTTP dataset kosong');
          }

          return Future.delayed(const Duration(milliseconds: 300))
              .then((_) => (_dioService as DioService)
                  .runActorWithInput(AppConstants.defaultActorInput));
        })
        .then((dioRes) {
          logs.add(_toLog('DIO (callback)', dioRes));
          _updateStats(dioRes, 'dio');
          print('✅ DIO callback completed');

          if (_hasData(dioRes)) {
            apiProducts.value = _mapItems(dioRes.result!.items!);
            print('✅ DIO: ${apiProducts.length} items disimpan');
          } else {
            print('⚠️ DIO dataset kosong');
          }

          if (dioRes.statusCode == 200) {
            print('🔗 [3/4] Starting chained callback...');
            return Future.delayed(const Duration(milliseconds: 200))
                .then((_) => _httpService.fetchApifyData(url));
          } else {
            throw Exception('Previous request failed');
          }
        })
        .then((chainedRes) {
          logs.add(_toLog('HTTP (chained callback)', chainedRes));
          _updateStats(chainedRes, 'http');
          print('✅ Chained callback completed');

          if (_hasData(chainedRes)) {
            apiProducts.value = _mapItems(chainedRes.result!.items!);
            print('✅ Chained: ${apiProducts.length} items disimpan');
          }

          stopwatch.stop();
          print('\n========================================');
          print('✅ CALLBACK TEST COMPLETED');
          print('⏱️ ${stopwatch.elapsedMilliseconds} ms');
          print('📦 Total items: ${apiProducts.length}');
          print('========================================\n');

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

  // HELPERS
  bool _hasData(ApiResult res) =>
      res.result?.items != null && res.result!.items!.isNotEmpty;

  List<Map<String, dynamic>> _mapItems(List<dynamic> items) {
    return items.map((item) {
      final categories = item['categories'];
      String category = '-';
      try {
        category =
            categories?[0]?['categories']?[0]?['categories']?[0]?['name'] ??
                '-';
      } catch (_) {}

      final price =
          item['price_instructions']?['unit_price']?.toString() ?? '-';
      final stock = 15;

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
      final current = type == 'http' ? avgHttpTime.value : avgDioTime.value;
      final count =
          logs.where((l) => l['library'].toString().contains(type.toUpperCase())).length;
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
    final rate = (successCount.value / totalTests.value * 100).toStringAsFixed(1);
    return '$rate%';
  }
}
