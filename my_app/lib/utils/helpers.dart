import 'dart:async';
import 'dart:math';
import 'package:intl/intl.dart';

class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({required this.delay});

  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

class Helpers {
  static Timer? _debounceTimer;

  // Global debounce helper (simple usage)
  static void debounce(void Function() callback,
      {Duration duration = const Duration(milliseconds: 400)}) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(duration, callback);
  }

  // Safe parse int
  static int toInt(dynamic val, {int fallback = 0}) {
    if (val == null) return fallback;
    if (val is int) return val;
    if (val is double) return val.toInt();
    return int.tryParse(val.toString()) ?? fallback;
  }

  // Safe parse double
  static double toDouble(dynamic val, {double fallback = 0.0}) {
    if (val == null) return fallback;
    if (val is double) return val;
    if (val is int) return val.toDouble();
    return double.tryParse(val.toString()) ?? fallback;
  }

  // Generate random alphanumeric ID
  static String randomId([int length = 10]) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rand = Random();
    return List.generate(length, (_) => chars[rand.nextInt(chars.length)])
        .join();
  }

  // Format date (requires intl)
  static String formatDate(DateTime date, {String pattern = 'yyyy-MM-dd'}) {
    return DateFormat(pattern).format(date);
  }

  // Format currency (default IDR)
  static String formatCurrency(num value,
      {String locale = 'id_ID', String symbol = 'Rp '}) {
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: 0,
    );
    return formatter.format(value);
  }
}

// String extensions
extension StringX on String {
  bool get isNumeric => num.tryParse(this) != null;

  String get capitalize {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }

  String get titleCase {
    return split(' ')
        .map((e) => e.isEmpty ? '' : e[0].toUpperCase() + e.substring(1))
        .join(' ');
  }
}

// Number extensions
extension NumX on num {
  String get toRupiah => Helpers.formatCurrency(this);
}

// List extensions
extension ListX<T> on List<T> {
  T? safeGet(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }
}
