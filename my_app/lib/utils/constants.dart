import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // ==========================================
  // APIFY CONFIGURATION
  // ==========================================
  static final apifyToken = dotenv.env['APIFY_TOKEN'];
  // Read ACTOR_ID from .env if present, otherwise fallback to the previous constant
  static final String actorId = dotenv.env['ACTOR_ID'] ?? 'zOiLZ2YwWpoBjhddk';

  // Helper to include token query only when token exists
  static String get _tokenQuery =>
      (apifyToken != null && apifyToken!.isNotEmpty)
      ? '?token=$apifyToken'
      : '';

  // Public alias for token query
  static String get tokenQuery => _tokenQuery;

  // ==========================================
  // APIFY ENDPOINTS
  // ==========================================

  // Option 1: Run actor dengan input (POST request)
  static String get runActorUrl =>
      'https://api.apify.com/v2/acts/$actorId/runs${_tokenQuery}';

  // Option 2: Get last run (GET request) - yang sekarang
  static String get lastRunUrl =>
      'https://api.apify.com/v2/acts/$actorId/runs/last${_tokenQuery}';

  // Option 3: Get dataset dari run terakhir (GET request)
  static String getDatasetUrl(String runId) =>
      'https://api.apify.com/v2/acts/$actorId/runs/$runId/dataset/items${_tokenQuery}';

  // Dataset by dataset id (some actors write to a separate dataset id)
  static String getDatasetById(String datasetId) =>
      'https://api.apify.com/v2/datasets/$datasetId/items${_tokenQuery}';

  // ==========================================
  // DEFAULT INPUT FOR ACTOR
  // ==========================================
  static Map<String, dynamic> get defaultActorInput => {
    'language': 'en',
    'query': 'Soy desserts',
  };

  // Alternative queries untuk kecap:
  static const List<String> kecapQueries = [
    'Soy Sauce',
    'Dark Soy Sauce',
    'Sweet Soy Sauce',
    'Kecap Manis',
    'Indonesian Soy Sauce',
  ];

  // ==========================================
  // ACTIVE URL
  // ==========================================

  // Untuk GET request (tanpa input)
  static String get apiUrl => lastRunUrl;

  // Untuk POST request (dengan input)
  static String get apiUrlWithInput => runActorUrl;
}
