class StopwatchHelper {
  static String formatMs(int ms) {
    if (ms < 1000) return '$ms ms';
    final s = ms ~/ 1000;
    final r = ms % 1000;
    return '${s}s ${r}ms';
  }
}