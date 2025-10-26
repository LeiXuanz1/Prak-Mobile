import 'package:dio/dio.dart';
import '../models/apify_result.dart';
import '../models/api_result.dart';
import '../../../../utils/constants.dart';
import 'api_service.dart';

class DioService implements ApiService {
  final Dio _dio = Dio();

  DioService() {
    // Configure Dio
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.sendTimeout = const Duration(seconds: 30);

    // Custom Interceptor untuk logging yang lebih detail
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print(
            '\n╔════════════════════════════════════════════════════════════',
          );
          print('║ ⚡ DIO SERVICE REQUEST');
          print(
            '╠════════════════════════════════════════════════════════════',
          );
          print('║ URL: ${options.uri}');
          print('║ Method: ${options.method}');
          if (options.data != null) {
            print('║ Data: ${options.data}');
          }
          print('║ Headers: ${options.headers}');
          print('║ Library: dio package');
          print(
            '╚════════════════════════════════════════════════════════════\n',
          );
          return handler.next(options);
        },
        onResponse: (response, handler) {
          final bytes = response.data.toString().length;
          print(
            '\n╔════════════════════════════════════════════════════════════',
          );
          print('║ ✅ DIO RESPONSE SUCCESS');
          print(
            '╠════════════════════════════════════════════════════════════',
          );
          print('║ Status Code: ${response.statusCode}');
          print(
            '║ Response Size: $bytes bytes (${(bytes / 1024).toStringAsFixed(2)} KB)',
          );
          print(
            '╚════════════════════════════════════════════════════════════\n',
          );
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          print(
            '\n╔════════════════════════════════════════════════════════════',
          );
          print('║ ❌ DIO ERROR');
          print(
            '╠════════════════════════════════════════════════════════════',
          );
          print('║ Error Type: ${e.type}');
          print('║ Message: ${e.message}');
          if (e.response != null) {
            print('║ Status Code: ${e.response?.statusCode}');
          }
          print(
            '╚════════════════════════════════════════════════════════════\n',
          );
          return handler.next(e);
        },
      ),
    );
  }

  // Poll the run status until SUCCEEDED (or terminal) or timeout
  Future<bool> _waitForRunCompletion(
    String runId, {
    required Duration timeout,
    required Duration interval,
  }) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      try {
        final statusUrl =
            'https://api.apify.com/v2/acts/${AppConstants.actorId}/runs/$runId${AppConstants.tokenQuery}';
        final res = await _dio.get(
          statusUrl,
          options: Options(validateStatus: (_) => true),
        );
        if (res.statusCode == 200) {
          final body = res.data;
          final status = body['data']?['status'] ?? body['status'];
          print('   - Poll status: $status');
          if (status == 'SUCCEEDED') return true;
          if (status == 'FAILED' ||
              status == 'ABORTED' ||
              status == 'TERMINATED')
            return false;
        } else {
          print('   - Poll status returned ${res.statusCode}');
        }
      } catch (e) {
        print('   - Poll error: $e');
      }

      await Future.delayed(interval);
    }
    return false;
  }

  // Method untuk POST request dengan input
  Future<ApiResult> runActorWithInput(Map<String, dynamic> input) async {
    final stopwatch = Stopwatch()..start();

    try {
      final response = await _dio.post(AppConstants.runActorUrl, data: input);
      stopwatch.stop();

      print('✅ DIO: Actor run started');

      // Get run ID and wait for completion
      final runId = response.data['data']?['id'];
      if (runId != null) {
        print('⏳ Waiting for actor to finish...');
        final completed = await _waitForRunCompletion(
          runId,
          timeout: const Duration(seconds: 60),
          interval: const Duration(seconds: 3),
        );
        if (completed) {
          return await fetchDatasetItems(runId);
        } else {
          return ApiResult(
            result: null,
            statusCode: response.statusCode ?? 202,
            durationMs: stopwatch.elapsedMilliseconds,
            responseBytes: response.data.toString().length,
            error: 'Run did not complete within timeout',
          );
        }
      }

      final bytes = response.data.toString().length;
      final data = ApifyResult.fromJson(response.data);

      return ApiResult(
        result: data,
        statusCode: response.statusCode ?? 200,
        durationMs: stopwatch.elapsedMilliseconds,
        responseBytes: bytes,
      );
    } on DioException catch (e) {
      stopwatch.stop();
      return _handleDioError(e, stopwatch.elapsedMilliseconds);
    } catch (e) {
      stopwatch.stop();
      print('❌ DIO POST Error: $e');
      return ApiResult(
        result: null,
        statusCode: 0,
        durationMs: stopwatch.elapsedMilliseconds,
        responseBytes: 0,
        error: 'Unexpected Dio error: $e',
      );
    }
  }

  // Method untuk fetch dataset items
  Future<ApiResult> fetchDatasetItems(String runId) async {
    final url = AppConstants.getDatasetUrl(runId);
    print('\n📦 Fetching dataset items from run: $runId\n');

    final stopwatch = Stopwatch()..start();

    try {
      final response = await _dio.get(
        url,
        options: Options(validateStatus: (_) => true),
      );
      stopwatch.stop();

      if (response.statusCode == 200) {
        if (response.data is List) {
          final items = response.data as List<dynamic>;
          if (items.isNotEmpty) {
            print('✅ DIO: Dataset fetched: ${items.length} items');
            final apifyData = ApifyResult(
              id: runId,
              status: 'SUCCEEDED',
              items: items,
              data: {'items': items},
            );
            final bytes = response.data.toString().length;
            return ApiResult(
              result: apifyData,
              statusCode: response.statusCode ?? 200,
              durationMs: stopwatch.elapsedMilliseconds,
              responseBytes: bytes,
            );
          }
          print('   - Dataset empty, will try run details to find dataset id');
        } else {
          print(
            '   - Dataset response is not a list, type=${response.data.runtimeType}',
          );
        }
      } else if (response.statusCode == 404) {
        print(
          '   - Dataset URL returned 404, will try run details to find dataset id',
        );
      } else {
        print('   - Dataset fetch returned ${response.statusCode}');
      }

      // Try run details to find defaultDatasetId
      try {
        final runUrl =
            'https://api.apify.com/v2/acts/${AppConstants.actorId}/runs/$runId${AppConstants.tokenQuery}';
        final runRes = await _dio.get(
          runUrl,
          options: Options(validateStatus: (_) => true),
        );
        if (runRes.statusCode == 200) {
          final runBody = runRes.data;
          final datasetId =
              runBody['data']?['defaultDatasetId'] ??
              runBody['defaultDatasetId'];
          if (datasetId != null) {
            final datasetUrl = AppConstants.getDatasetById(datasetId);
            print('   - Found datasetId: $datasetId, fetching $datasetUrl');
            final dsRes = await _dio.get(
              datasetUrl,
              options: Options(validateStatus: (_) => true),
            );
            if (dsRes.statusCode == 200) {
              final items = dsRes.data as List<dynamic>;
              print('✅ Dataset by id fetched: ${items.length} items');
              final apifyData = ApifyResult(
                id: runId,
                status: 'SUCCEEDED',
                items: items,
                data: {'items': items},
              );
              return ApiResult(
                result: apifyData,
                statusCode: 200,
                durationMs: stopwatch.elapsedMilliseconds,
                responseBytes: dsRes.data.toString().length,
              );
            } else {
              print('   - Dataset by id fetch returned ${dsRes.statusCode}');
            }
          } else {
            print('   - defaultDatasetId not found in run details');
          }
        } else {
          print('   - run details fetch returned ${runRes.statusCode}');
        }
      } catch (e) {
        print('   - run details fetch error: $e');
      }

      return ApiResult(
        result: null,
        statusCode: response.statusCode ?? 0,
        durationMs: stopwatch.elapsedMilliseconds,
        responseBytes: 0,
        error: 'Failed to fetch dataset or dataset empty',
      );
    } on DioException catch (e) {
      stopwatch.stop();
      return _handleDioError(e, stopwatch.elapsedMilliseconds);
    }
  }

  @override
  Future<ApiResult> fetchApifyData(String url) async {
    final stopwatch = Stopwatch()..start();

    try {
      final response = await _dio.get(url);
      stopwatch.stop();

      final bytes = response.data.toString().length;

      print('✅ DIO: Data fetched successfully');
      print('   - Duration: ${stopwatch.elapsedMilliseconds} ms');
      print('   - Size: $bytes bytes');

      final data = ApifyResult.fromJson(response.data);
      print('✅ DIO: JSON parsed successfully');
      print('   - Status: ${data.status}');
      print('   - Items count: ${data.items?.length ?? 0}');

      return ApiResult(
        result: data,
        statusCode: response.statusCode ?? 200,
        durationMs: stopwatch.elapsedMilliseconds,
        responseBytes: bytes,
      );
    } on DioException catch (e) {
      stopwatch.stop();
      return _handleDioError(e, stopwatch.elapsedMilliseconds);
    } catch (e) {
      stopwatch.stop();
      print('❌ Unexpected DIO error: $e');
      return ApiResult(
        result: null,
        statusCode: 0,
        durationMs: stopwatch.elapsedMilliseconds,
        responseBytes: 0,
        error: 'Unexpected Dio error: $e',
      );
    }
  }

  // Helper method untuk handle DIO errors
  ApiResult _handleDioError(DioException e, int durationMs) {
    String errorMessage;
    int statusCode = 0;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        errorMessage = 'Connection Timeout - Server tidak merespons';
        statusCode = 408;
        print('❌ DIO: Connection timeout');
        break;

      case DioExceptionType.sendTimeout:
        errorMessage = 'Send Timeout - Gagal mengirim request';
        statusCode = 408;
        print('❌ DIO: Send timeout');
        break;

      case DioExceptionType.receiveTimeout:
        errorMessage = 'Receive Timeout - Gagal menerima response';
        statusCode = 408;
        print('❌ DIO: Receive timeout');
        break;

      case DioExceptionType.badResponse:
        errorMessage = 'Bad Response - Server error ${e.response?.statusCode}';
        statusCode = e.response?.statusCode ?? 500;
        print('❌ DIO: Bad response (${e.response?.statusCode})');
        break;

      case DioExceptionType.cancel:
        errorMessage = 'Request Cancelled';
        statusCode = 0;
        print('❌ DIO: Request cancelled');
        break;

      case DioExceptionType.connectionError:
        errorMessage = 'Connection Error - Tidak ada koneksi internet';
        statusCode = 0;
        print('❌ DIO: Connection error');
        break;

      case DioExceptionType.badCertificate:
        errorMessage = 'Bad Certificate - SSL/TLS error';
        statusCode = 0;
        print('❌ DIO: Bad certificate');
        break;

      case DioExceptionType.unknown:
        errorMessage = 'Unknown Error: ${e.message}';
        statusCode = 0;
        print('❌ DIO: Unknown error');
        break;
    }

    return ApiResult(
      result: null,
      statusCode: statusCode,
      durationMs: durationMs,
      responseBytes: 0,
      error: errorMessage,
    );
  }
}
