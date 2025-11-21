import 'apify_result.dart';

class ApiResult {
  final ApifyResult? result;
  final int statusCode;
  final int durationMs;
  final int responseBytes;
  final String? error;

  ApiResult({
    this.result,
    required this.statusCode,
    required this.durationMs,
    required this.responseBytes,
    this.error,
  });
}
