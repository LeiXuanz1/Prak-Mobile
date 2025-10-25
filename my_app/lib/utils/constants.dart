import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static final apifyToken = dotenv.env['APIFY_TOKEN'];

  static const String actorId = 'zOiLZ2YwWpoBjhddk';

  static String get apiUrl =>
      'https://api.apify.com/v2/acts/$actorId/runs/last?token=$apifyToken';
}