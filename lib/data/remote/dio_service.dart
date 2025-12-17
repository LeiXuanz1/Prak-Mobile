import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import '../../modules/apify/models/apify_result.dart';
import '../../modules/apify/models/api_result.dart';
import '../../core/constants/api_constants.dart';
import 'api_service.dart';

class DioService implements ApiService {
  final Dio _dio = Dio();

  DioService() {
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (response.data is String &&
              response.data.toString().trim().startsWith('{')) {
            response.data = jsonDecode(response.data);
          }

          return handler.next(response);
        },
        onError: (DioException e, handler) {
          return handler.next(e);
        },
      ),
    );
  }

  // Fetch Apify Data (GET)
  @override
  Future<ApiResult> fetchApifyData(String url) async {
    final stopwatch = Stopwatch()..start();
    try {
      final response = await _dio.get(url);
      stopwatch.stop();

      final bytes = response.data.toString().length;

      ApifyResult apifyResult;

      // Jika data dari API berupa List
      if (response.data is List) {
        apifyResult = ApifyResult(
          items: List<Map<String, dynamic>>.from(response.data),
        );
      } else if (response.data is Map<String, dynamic>) {
        apifyResult = ApifyResult.fromJson(response.data);
      } else {
        throw Exception(
          'Unexpected response format: ${response.data.runtimeType}',
        );
      }

      return ApiResult(
        result: apifyResult,
        statusCode: response.statusCode ?? 200,
        durationMs: stopwatch.elapsedMilliseconds,
        responseBytes: bytes,
      );
    } on DioException catch (e) {
      stopwatch.stop();
      return _handleDioError(e, stopwatch.elapsedMilliseconds);
    } catch (e) {
      stopwatch.stop();
      return ApiResult(
        result: null,
        statusCode: 0,
        durationMs: stopwatch.elapsedMilliseconds,
        responseBytes: 0,
        error: 'Unexpected Dio error: $e',
      );
    }
  }

  // Run actor
  Future<ApiResult> runActorWithInput(Map<String, dynamic> input) async {
    final stopwatch = Stopwatch()..start();

    try {
      final response = await _dio.get(AppConstants.apiUrl);
      stopwatch.stop();

      // 🔧 Parse ke model ApifyResult
      final parsedResult = ApifyResult.fromJson(response.data);

      return ApiResult(
        result: parsedResult,
        statusCode: response.statusCode ?? 200,
        durationMs: stopwatch.elapsedMilliseconds,
        responseBytes: response.data.toString().length,
        error: null,
      );
    } on DioException catch (e) {
      stopwatch.stop();
      return _handleDioError(e, stopwatch.elapsedMilliseconds);
    }
  }

  // Fetch dataset items dari run terakhir
  Future<ApiResult> fetchDatasetItems(String runId) async {
    final stopwatch = Stopwatch()..start();
    final url = AppConstants.apiUrl;

    try {
      final response = await _dio.get(url);
      stopwatch.stop();

      if (response.statusCode == 200 && response.data is List) {
        final items = List<dynamic>.from(response.data);

        final result = ApifyResult(items: items);
        return ApiResult(
          result: result,
          statusCode: 200,
          durationMs: stopwatch.elapsedMilliseconds,
          responseBytes: response.data.toString().length,
        );
      }

      return ApiResult(
        result: null,
        statusCode: response.statusCode ?? 0,
        durationMs: stopwatch.elapsedMilliseconds,
        responseBytes: 0,
        error: 'Invalid dataset format or empty dataset',
      );
    } on DioException catch (e) {
      stopwatch.stop();
      return _handleDioError(e, stopwatch.elapsedMilliseconds);
    }
  }

  // Wait until Apify run selesai
  Future<bool> waitForRunCompletion(
    String runId, {
    required Duration timeout,
    required Duration interval,
  }) async {
    final end = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(end)) {
      try {
        final statusUrl =
            'https://api.apify.com/v2/acts/${AppConstants.datasetId}/runs/$runId${AppConstants.tokenQuery}';
        final res = await _dio.get(statusUrl);
        final status = res.data['data']?['status'] ?? res.data['status'];

        if (status == 'SUCCEEDED') return true;
        if (['FAILED', 'ABORTED', 'TERMINATED'].contains(status)) return false;
      } catch (e) {
        log("Poll error", error: e);
      }

      await Future.delayed(interval);
    }

    return false;
  }

  // Error handler
  ApiResult _handleDioError(DioException e, int durationMs) {
    String msg;
    int code = 0;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        msg = 'Connection Timeout';
        code = 408;
        break;
      case DioExceptionType.receiveTimeout:
        msg = 'Receive Timeout';
        code = 408;
        break;
      case DioExceptionType.badResponse:
        msg = 'Bad Response (${e.response?.statusCode})';
        code = e.response?.statusCode ?? 500;
        break;
      case DioExceptionType.connectionError:
        msg = 'No Internet Connection';
        code = 0;
        break;
      case DioExceptionType.cancel:
        msg = 'Request Cancelled';
        break;
      default:
        msg = 'Unknown Error: ${e.message}';
        break;
    }

    return ApiResult(
      result: null,
      statusCode: code,
      durationMs: durationMs,
      responseBytes: 0,
      error: msg,
    );
  }
}
