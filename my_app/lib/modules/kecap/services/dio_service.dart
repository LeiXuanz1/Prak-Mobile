import 'package:dio/dio.dart';
import '../models/apify_result.dart';
import '../models/api_result.dart';
import 'api_service.dart';

class DioService implements ApiService {
  final Dio _dio = Dio();

  DioService() {
    // Tambahkan LogInterceptor bawaan Dio agar terlihat lebih detail di console
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      error: true,
    ));

    // Interceptor tambahan untuk custom print log ringkas
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print('🚀 DIO REQUEST => ${options.method} ${options.uri}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('✅ DIO RESPONSE => ${response.statusCode}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        print('❌ DIO ERROR: ${e.message}');
        return handler.next(e);
      },
    ));
  }

  @override
  Future<ApiResult> fetchApifyData(String url) async {
    final stopwatch = Stopwatch()..start();
    try {
      // Gunakan URL dari parameter
      final response = await _dio.get(url);
      stopwatch.stop();

      dynamic raw = response.data;
      ApifyResult data;

      // Apify API mengembalikan array JSON
      if (raw is List) {
        data = ApifyResult(items: raw);
      } else if (raw is Map<String, dynamic>) {
        data = ApifyResult.fromJson(raw);
      } else {
        data = ApifyResult(items: []);
      }

      final bytes = response.data.toString().length;

      return ApiResult(
        result: data,
        statusCode: response.statusCode ?? 200,
        durationMs: stopwatch.elapsedMilliseconds,
        responseBytes: bytes,
      );
    } catch (e) {
      stopwatch.stop();
      return ApiResult(
        result: null,
        statusCode: 0,
        durationMs: stopwatch.elapsedMilliseconds,
        responseBytes: 0,
        error: e.toString(),
      );
    }
  }
}
