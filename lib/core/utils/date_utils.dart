class AppDateUtils {
  /// Mendapatkan batas awal hari custom (jam 7 pagi)
  /// Jika saat ini sebelum jam 7 pagi, maka dianggap bagian dari hari kemarin
  static DateTime getStartOfCustomDay(DateTime now) {
    if (now.hour < 7) {
      // Sebelum jam 7 pagi, terhitung hari sebelumnya jam 7 pagi
      return DateTime(now.year, now.month, now.day - 1, 7, 0, 0);
    } else {
      // Jam 7 pagi ke atas, terhitung hari ini jam 7 pagi
      return DateTime(now.year, now.month, now.day, 7, 0, 0);
    }
  }

  /// Mendapatkan batas akhir hari custom (jam 6:59:59 keesokan harinya)
  static DateTime getEndOfCustomDay(DateTime now) {
    final start = getStartOfCustomDay(now);
    // Tambah 1 hari, lalu kurangi 1 detik
    return start.add(const Duration(days: 1)).subtract(const Duration(seconds: 1));
  }

  /// Mendapatkan key string unik untuk hari custom ini (misal untuk SharedPreferences)
  /// Format: yyyy-mm-dd berdasarkan start of custom day
  static String getCustomDayKey(DateTime now) {
    final start = getStartOfCustomDay(now);
    return "${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}";
  }
}
