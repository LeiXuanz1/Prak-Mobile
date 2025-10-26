import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/api_result.dart';
import '../models/apify_result.dart';
import 'api_service.dart';
import '/utils/constants.dart';

class HttpService implements ApiService {
  // Method untuk POST request dengan input
  Future<ApiResult> runActorWithInput(Map<String, dynamic> input) async {
    print('\n╔════════════════════════════════════════════════════════════');
    print('║ 🌐 HTTP SERVICE REQUEST (POST with Input)');
    print('╠════════════════════════════════════════════════════════════');
    print('║ URL: ${AppConstants.runActorUrl}');
    print('║ Method: POST');
    print('║ Library: http package');
    print('║ Input: ${jsonEncode(input)}');
    print('╚════════════════════════════════════════════════════════════\n');

    final stopwatch = Stopwatch()..start();

    try {
      final response = await http.post(
        Uri.parse(AppConstants.runActorUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(input),
      );
      stopwatch.stop();

      final body = response.body;
      final bytes = body.length;

      print('\n╔════════════════════════════════════════════════════════════');
      print('║ ✅ HTTP RESPONSE (POST)');
      print('╠════════════════════════════════════════════════════════════');
      print('║ Status Code: ${response.statusCode}');
      print('║ Duration: ${stopwatch.elapsedMilliseconds} ms');
      print(
        '║ Response Size: $bytes bytes (${(bytes / 1024).toStringAsFixed(2)} KB)',
      );
      print('╚════════════════════════════════════════════════════════════\n');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final data = jsonDecode(body);
          print('✅ Actor run started: ${data['data']?['id']}');
          print('   - Status: ${data['data']?['status']}');

          // Wait for run to complete, then fetch dataset
          final runId = data['data']?['id'];
          if (runId != null) {
            print('⏳ Waiting for actor to finish...');
            // Wait for run completion with polling
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
                statusCode: 202,
                durationMs: stopwatch.elapsedMilliseconds,
                responseBytes: bytes,
                error: 'Run did not complete within timeout',
              );
            }
          }

          final apifyData = ApifyResult.fromJson(data);
          return ApiResult(
            result: apifyData,
            statusCode: response.statusCode,
            durationMs: stopwatch.elapsedMilliseconds,
            responseBytes: bytes,
          );
        } catch (parseError) {
          print('⚠️  JSON Parse Error: $parseError');
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
      print('❌ HTTP POST Error: $e');
      return ApiResult(
        result: null,
        statusCode: 0,
        durationMs: stopwatch.elapsedMilliseconds,
        responseBytes: 0,
        error: 'Unexpected error: $e',
      );
    }
  }

  // Method untuk fetch dataset items (hasil scraping)
  Future<ApiResult> fetchDatasetItems(String runId) async {
    final url = AppConstants.getDatasetUrl(runId);
    print('\n📦 Fetching dataset items from run: $runId');
    print('   URL: $url\n');

    final stopwatch = Stopwatch()..start();

    try {
      final response = await http.get(Uri.parse(url));
      stopwatch.stop();

      final body = response.body;
      final bytes = body.length;

      if (response.statusCode == 200) {
        final List<dynamic> items = jsonDecode(body);
        print('✅ Dataset fetched: ${items.length} items');

        if (items.isNotEmpty) {
          final apifyData = ApifyResult(
            id: runId,
            status: 'SUCCEEDED',
            items: items,
            data: {'items': items},
          );

          return ApiResult(
            result: apifyData,
            statusCode: response.statusCode,
            durationMs: stopwatch.elapsedMilliseconds,
            responseBytes: bytes,
          );
        }

        // If empty, fallthrough to try getting dataset by defaultDatasetId
        print('   - Dataset empty, will try run details to find dataset id');
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
        final runRes = await http.get(Uri.parse(runUrl));
        if (runRes.statusCode == 200) {
          final runBody = jsonDecode(runRes.body);
          final datasetId =
              runBody['data']?['defaultDatasetId'] ??
              runBody['defaultDatasetId'];
          if (datasetId != null) {
            final datasetUrl = AppConstants.getDatasetById(datasetId);
            print('   - Found datasetId: $datasetId, fetching $datasetUrl');
            final dsRes = await http.get(Uri.parse(datasetUrl));
            if (dsRes.statusCode == 200) {
              final items = jsonDecode(dsRes.body) as List<dynamic>;
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
                responseBytes: dsRes.body.length,
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
    print('\n╔════════════════════════════════════════════════════════════');
    print('║ 🌐 HTTP SERVICE REQUEST');
    print('╠════════════════════════════════════════════════════════════');
    print('║ URL: $url');
    print('║ Method: GET');
    print('║ Library: http package');
    print('╚════════════════════════════════════════════════════════════\n');

    final stopwatch = Stopwatch()..start();

    try {
      final response = await http.get(Uri.parse(url));
      stopwatch.stop();

      final body = response.body;
      final bytes = body.length;

      print('\n╔════════════════════════════════════════════════════════════');
      print('║ ✅ HTTP RESPONSE SUCCESS');
      print('╠════════════════════════════════════════════════════════════');
      print('║ Status Code: ${response.statusCode}');
      print('║ Duration: ${stopwatch.elapsedMilliseconds} ms');
      print(
        '║ Response Size: $bytes bytes (${(bytes / 1024).toStringAsFixed(2)} KB)',
      );
      print('║ Content-Type: ${response.headers['content-type'] ?? 'unknown'}');
      print('╚════════════════════════════════════════════════════════════\n');

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(body);
          final apifyData = ApifyResult.fromJson(data);

          print('✅ JSON parsed successfully');
          print('   - Status: ${apifyData.status}');
          print('   - Items count: ${apifyData.items?.length ?? 0}');

          return ApiResult(
            result: apifyData,
            statusCode: response.statusCode,
            durationMs: stopwatch.elapsedMilliseconds,
            responseBytes: bytes,
          );
        } catch (parseError) {
          print('⚠️  JSON Parse Error: $parseError');
          return ApiResult(
            result: null,
            statusCode: response.statusCode,
            durationMs: stopwatch.elapsedMilliseconds,
            responseBytes: bytes,
            error: 'JSON Parse Error: $parseError',
          );
        }
      } else {
        print(
          '\n╔════════════════════════════════════════════════════════════',
        );
        print('║ ⚠️  HTTP RESPONSE ERROR');
        print('╠════════════════════════════════════════════════════════════');
        print('║ Status Code: ${response.statusCode}');
        print('║ Error: HTTP Error ${response.statusCode}');
        print('║ Duration: ${stopwatch.elapsedMilliseconds} ms');
        print(
          '╚════════════════════════════════════════════════════════════\n',
        );

        return ApiResult(
          result: null,
          statusCode: response.statusCode,
          durationMs: stopwatch.elapsedMilliseconds,
          responseBytes: bytes,
          error: 'HTTP Error: ${response.statusCode}',
        );
      }
    } on SocketException catch (e) {
      stopwatch.stop();
      print('\n╔════════════════════════════════════════════════════════════');
      print('║ ❌ NETWORK ERROR');
      print('╠════════════════════════════════════════════════════════════');
      print('║ Error Type: No Internet Connection');
      print('║ Details: ${e.message}');
      print('║ Duration: ${stopwatch.elapsedMilliseconds} ms');
      print('╚════════════════════════════════════════════════════════════\n');

      return ApiResult(
        result: null,
        statusCode: 0,
        durationMs: stopwatch.elapsedMilliseconds,
        responseBytes: 0,
        error: 'No Internet Connection',
      );
    } on HttpException catch (e) {
      stopwatch.stop();
      print('\n╔════════════════════════════════════════════════════════════');
      print('║ ❌ HTTP EXCEPTION');
      print('╠════════════════════════════════════════════════════════════');
      print('║ Error Type: Invalid HTTP response');
      print('║ Details: ${e.message}');
      print('║ Duration: ${stopwatch.elapsedMilliseconds} ms');
      print('╚════════════════════════════════════════════════════════════\n');

      return ApiResult(
        result: null,
        statusCode: 0,
        durationMs: stopwatch.elapsedMilliseconds,
        responseBytes: 0,
        error: 'Invalid HTTP response',
      );
    } on FormatException catch (e) {
      stopwatch.stop();
      print('\n╔════════════════════════════════════════════════════════════');
      print('║ ❌ FORMAT EXCEPTION');
      print('╠════════════════════════════════════════════════════════════');
      print('║ Error Type: Invalid JSON format');
      print('║ Details: ${e.message}');
      print('║ Duration: ${stopwatch.elapsedMilliseconds} ms');
      print('╚════════════════════════════════════════════════════════════\n');

      return ApiResult(
        result: null,
        statusCode: 0,
        durationMs: stopwatch.elapsedMilliseconds,
        responseBytes: 0,
        error: 'Invalid JSON format',
      );
    } on TimeoutException catch (e) {
      stopwatch.stop();
      print('\n╔════════════════════════════════════════════════════════════');
      print('║ ❌ TIMEOUT ERROR');
      print('╠════════════════════════════════════════════════════════════');
      print('║ Error Type: Request Timeout');
      print('║ Details: ${e.message}');
      print('║ Duration: ${stopwatch.elapsedMilliseconds} ms');
      print('╚════════════════════════════════════════════════════════════\n');

      return ApiResult(
        result: null,
        statusCode: 408,
        durationMs: stopwatch.elapsedMilliseconds,
        responseBytes: 0,
        error: 'Request Timeout',
      );
    } catch (e) {
      stopwatch.stop();
      print('\n╔════════════════════════════════════════════════════════════');
      print('║ ❌ UNEXPECTED ERROR');
      print('╠════════════════════════════════════════════════════════════');
      print('║ Error Type: Unknown');
      print('║ Details: $e');
      print('║ Duration: ${stopwatch.elapsedMilliseconds} ms');
      print('╚════════════════════════════════════════════════════════════\n');

      return ApiResult(
        result: null,
        statusCode: 0,
        durationMs: stopwatch.elapsedMilliseconds,
        responseBytes: 0,
        error: 'Unexpected error: $e',
      );
    }
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
        final res = await http.get(Uri.parse(statusUrl));
        if (res.statusCode == 200) {
          final body = jsonDecode(res.body);
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
}
