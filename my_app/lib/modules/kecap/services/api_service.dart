import '../models/api_result.dart';

abstract class ApiService {
  Future<ApiResult> fetchApifyData(String url);
}
