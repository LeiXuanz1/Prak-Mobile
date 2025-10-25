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

  // Eksperimen Performa HTTP Library
  Future<void> runComparison() async {
    loading.value = true;
    logs.clear();

    final url = AppConstants.apiUrl;

    // HTTP (async–await)
    final httpRes = await _httpService.fetchApifyData(url);
    logs.add(_toLog('HTTP (async–await)', httpRes));

    await Future.delayed(const Duration(milliseconds: 100));

    // DIO (async–await)
    final dioRes = await _dioService.fetchApifyData(url);
    logs.add(_toLog('DIO (async–await)', dioRes));

    lastStatus.value =
        dioRes.result?.status ?? httpRes.result?.status ?? 'unknown';

    loading.value = false;
  }

  // Callback Chaining
  void runComparisonCallback() {
    loading.value = true;
    logs.clear();

    final url = AppConstants.apiUrl;

    final stopwatch = Stopwatch()..start();

    // Contoh chaining menggunakan HTTP service
    _httpService.fetchApifyData(url).then((httpRes) {
      stopwatch.stop();
      logs.add(_toLog('HTTP (callback)', httpRes));
      // Simulasi chained request (misal: ambil detail berdasarkan hasil pertama)
      final nextUrl = url;
      stopwatch.reset();
      stopwatch.start();
      return _dioService.fetchApifyData(nextUrl);
    }).then((dioRes) {
      stopwatch.stop();
      logs.add(_toLog('DIO (callback)', dioRes));
      lastStatus.value = dioRes.result?.status ?? 'unknown';
    }).catchError((error) {
      logs.add({
        'library': 'Callback Chain',
        'status': 'error',
        'duration': '-',
        'bytes': '-',
        'error': error.toString(),
      });
    }).whenComplete(() {
      loading.value = false;
    });
  }

  // Utility: Logging hasil
  Map<String, dynamic> _toLog(String lib, ApiResult res) {
    return {
      'library': lib,
      'status': res.statusCode,
      'duration': '${res.durationMs} ms',
      'bytes': res.responseBytes,
      'error': res.error,
    };
  }
}
