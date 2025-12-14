import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../../modules/apify/models/api_result.dart';
import '../../modules/apify/models/apify_result.dart';
import 'api_service.dart';
import '../../core/constants/api_constants.dart';

class HttpService implements ApiService {
  // GET request dengan input (tidak dipakai body karena pakai GET)
  Future<ApiResult> runActorWithInput(Map<String, dynamic> input) async {
    final stopwatch = Stopwatch()..start();

    try {
      final response = await http.get(
        Uri.parse(AppConstants.apiUrl),
        headers: {'Content-Type': 'application/json'},
      );
      stopwatch.stop();

      final body = response.body;
      final bytes = body.length;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final data = jsonDecode(body);

          // langsung parse ke ApifyResult
          final apifyData = ApifyResult.fromJson(data);

          return ApiResult(
            result: apifyData,
            statusCode: response.statusCode,
            durationMs: stopwatch.elapsedMilliseconds,
            responseBytes: bytes,
          );
        } catch (parseError) {
          return ApiResult(
            result: null,
            statusCode: response.statusCode,
            durationMs: stopwatch.elapsedMilliseconds,
            responseBytes: bytes,
            error: 'JSON Parse Error: $parseError',
          );
        }
      } else {
        return ApiResult(
          result: null,
          statusCode: response.statusCode,
          durationMs: stopwatch.elapsedMilliseconds,
          responseBytes: bytes,
          error: 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      stopwatch.stop();
      return ApiResult(
        result: null,
        statusCode: 0,
        durationMs: stopwatch.elapsedMilliseconds,
        responseBytes: 0,
        error: 'Unexpected error: $e',
      );
    }
  }

  // fetch dataset items
  Future<ApiResult> fetchDatasetItems(String runId) async {
    final url = AppConstants.apiUrl;

    final stopwatch = Stopwatch()..start();

    try {
      final response = await http.get(Uri.parse(url));
      stopwatch.stop();

      final body = response.body;
      final bytes = body.length;

      if (response.statusCode == 200) {
        final data = jsonDecode(body);
        final apifyData = ApifyResult.fromJson(data);

        return ApiResult(
          result: apifyData,
          statusCode: response.statusCode,
          durationMs: stopwatch.elapsedMilliseconds,
          responseBytes: bytes,
        );
      }

      return ApiResult(
        result: null,
        statusCode: response.statusCode,
        durationMs: stopwatch.elapsedMilliseconds,
        responseBytes: bytes,
        error: 'Failed to fetch dataset or dataset empty',
      );
    } catch (e) {
      stopwatch.stop();
      return ApiResult(
        result: null,
        statusCode: 0,
        durationMs: stopwatch.elapsedMilliseconds,
        responseBytes: 0,
        error: 'Dataset fetch error: $e',
      );
    }
  }

  @override
  Future<ApiResult> fetchApifyData(String url) async {
    final stopwatch = Stopwatch()..start();

    try {
      final response = await http.get(Uri.parse(url));
      stopwatch.stop();

      final body = response.body;
      final bytes = body.length;

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(body);
          final apifyData = ApifyResult.fromJson(data);

          return ApiResult(
            result: apifyData,
            statusCode: response.statusCode,
            durationMs: stopwatch.elapsedMilliseconds,
            responseBytes: bytes,
          );
        } catch (parseError) {
          return ApiResult(
            result: null,
            statusCode: response.statusCode,
            durationMs: stopwatch.elapsedMilliseconds,
            responseBytes: bytes,
            error: 'JSON Parse Error: $parseError',
          );
        }
      } else {
        return ApiResult(
          result: null,
          statusCode: response.statusCode,
          durationMs: stopwatch.elapsedMilliseconds,
          responseBytes: bytes,
          error: 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      stopwatch.stop();
      return ApiResult(
        result: null,
        statusCode: 0,
        durationMs: stopwatch.elapsedMilliseconds,
        responseBytes: 0,
        error: 'Unexpected error: $e',
      );
    }
  }

  // polling run completion (tidak dihapus karena masih bisa dipakai kalau endpoint-nya ada runId)
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
        final res = await http.get(Uri.parse(statusUrl));
        if (res.statusCode == 200) {
          final body = jsonDecode(res.body);
          final status = body['data']?['status'] ?? body['status'];

          if (status == 'SUCCEEDED') return true;

          if (status == 'FAILED' ||
              status == 'ABORTED' ||
              status == 'TERMINATED') {
                return false;
              }
        } else {
          log("Poll status returned: ${res.statusCode}");
        }
      } catch (e) {
        log("Poll error", error: e);
      }

      await Future.delayed(interval);
    }
    return false;
  }
}
