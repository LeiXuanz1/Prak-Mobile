import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static final apifyToken = dotenv.env['APIFY_TOKEN'];

  static const datasetId = 'Pm5yP69vyU9QiyOXu';

  static String get apiUrl =>
      'https://api.apify.com/v2/datasets/$datasetId/items?token=$apifyToken';
}