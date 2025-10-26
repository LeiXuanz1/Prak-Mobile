import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:my_app/utils/constants.dart';
import '../models/api_result.dart';
import '../models/apify_result.dart';
import 'api_service.dart';

class HttpService implements ApiService {
  @override
  Future<ApiResult> fetchApifyData(String url) async {
    final stopwatch = Stopwatch()..start();

    try {
      final response = await http.get(Uri.parse(AppConstants.apiUrl));
      stopwatch.stop();

      final body = response.body;
      final bytes = body.length;

      if (response.statusCode == 200) {
        final decoded = jsonDecode(body);
        ApifyResult apifyData;

        // ✅ Handle jika response berupa List, bukan Map
        if (decoded is List) {
          apifyData = ApifyResult(items: decoded);
        } else if (decoded is Map<String, dynamic>) {
          apifyData = ApifyResult.fromJson(decoded);
        } else {
          apifyData = ApifyResult(items: []);
        }

        return ApiResult(
          result: apifyData,
          statusCode: response.statusCode,
          durationMs: stopwatch.elapsedMilliseconds,
          responseBytes: bytes,
        );
      } else {
        return ApiResult(
          result: null,
          statusCode: response.statusCode,
          durationMs: stopwatch.elapsedMilliseconds,
          responseBytes: bytes,
          error: 'HTTP Error: ${response.statusCode}',
        );
      }
    } on SocketException {
      stopwatch.stop();
      return ApiResult(
        result: null,
        statusCode: 0,
        durationMs: stopwatch.elapsedMilliseconds,
        responseBytes: 0,
        error: 'No Internet Connection',
      );
    } on HttpException {
      stopwatch.stop();
      return ApiResult(
        result: null,
        statusCode: 0,
        durationMs: stopwatch.elapsedMilliseconds,
        responseBytes: 0,
        error: 'Invalid HTTP response',
      );
    } on FormatException {
      stopwatch.stop();
      return ApiResult(
        result: null,
        statusCode: 0,
        durationMs: stopwatch.elapsedMilliseconds,
        responseBytes: 0,
        error: 'Invalid JSON format',
      );
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
}
