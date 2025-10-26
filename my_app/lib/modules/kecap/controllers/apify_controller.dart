import 'package:get/get.dart';
import '../models/api_result.dart';
import '../services/http_service.dart';
import '../services/dio_service.dart';
import '../services/api_service.dart';
import '/utils/constants.dart';
import '/modules/kecap/models/soy_sauce.dart';

class ApifyController extends GetxController {
  final ApiService _httpService = HttpService();
  final ApiService _dioService = DioService();

  final RxList<Map<String, dynamic>> logs = <Map<String, dynamic>>[].obs;
  final RxBool loading = false.obs;
  final RxString lastStatus = ''.obs;
  final RxList<SoySauce> soySauces = <SoySauce>[].obs;

  // 🔹 Eksperimen Performa HTTP Library
  Future<void> runComparison() async {
    loading.value = true;
    logs.clear();

    final url = AppConstants.apiUrl;

    // HTTP (async–await)
    final httpRes = await _httpService.fetchApifyData(url);
    print('📦 HTTP RESULT BODY => ${httpRes.result}');
    logs.add(_toLog('HTTP (async–await)', httpRes));

    await Future.delayed(const Duration(milliseconds: 100));

    // DIO (async–await)
    final dioRes = await _dioService.fetchApifyData(url);
    print('📦 DIO RESULT BODY => ${dioRes.result}');
    logs.add(_toLog('DIO (async–await)', dioRes));

    if (dioRes.result != null && dioRes.result!.items.isNotEmpty) {
      final dataList = dioRes.result!.items;

      soySauces.value = dataList.map((item) {
        return SoySauce(
          id: item['id']?.toString() ?? '0',
          name: item['display_name'] ?? 'Tanpa nama',
          price: (item['price_instructions']?['unit_price'] is num)
              ? item['price_instructions']['unit_price'].toDouble()
              : double.tryParse(item['price_instructions']?['unit_price']?.toString() ?? '0') ?? 0.0,
          imageUrl: item['thumbnail'] ?? '',
          link: item['share_url'] ?? '',
        );
      }).toList();

      print('✅ ${soySauces.length} produk soy sauce dimuat');
    } else {
      print('⚠️ Tidak ada data soy sauce di respons Apify');
    }

    lastStatus.value =
        dioRes.statusCode.toString().isNotEmpty ? dioRes.statusCode.toString() : httpRes.statusCode.toString();

    loading.value = false;
  }

  // 🔹 Callback Chaining
  void runComparisonCallback() {
    loading.value = true;
    logs.clear();

    final url = AppConstants.apiUrl;
    final stopwatch = Stopwatch()..start();

    _httpService.fetchApifyData(url).then((httpRes) {
      stopwatch.stop();
      logs.add(_toLog('HTTP (callback)', httpRes));
      final nextUrl = url;
      stopwatch.reset();
      stopwatch.start();
      return _dioService.fetchApifyData(nextUrl);
    }).then((dioRes) {
      stopwatch.stop();
      logs.add(_toLog('DIO (callback)', dioRes));
      lastStatus.value = dioRes.statusCode.toString();
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

  // 🔹 Utility: Logging hasil
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
