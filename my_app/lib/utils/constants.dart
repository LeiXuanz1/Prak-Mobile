import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static final apifyToken = dotenv.env['APIFY_TOKEN'];
  static final String actorId = dotenv.env['ACTOR_ID'] ?? 'zOiLZ2YwWpoBjhddk';
  static const datasetId = 'Pm5yP69vyU9QiyOXu';

  static String get _tokenQuery =>
      (apifyToken != null && apifyToken!.isNotEmpty)
          ? '?token=$apifyToken'
          : '';

  static String get tokenQuery => _tokenQuery;

  static String getDatasetById(String datasetId) =>
      'https://api.apify.com/v2/datasets/$datasetId/items${_tokenQuery}';

  static Map<String, dynamic> get defaultActorInput => {
        'language': 'en',
        'query': 'Soy desserts',
      };

  static const List<String> kecapQueries = [
    'Soy Sauce',
    'Dark Soy Sauce',
    'Sweet Soy Sauce',
    'Kecap Manis',
    'Indonesian Soy Sauce',
  ];

  static String get apiUrl => getDatasetById(datasetId);
}
