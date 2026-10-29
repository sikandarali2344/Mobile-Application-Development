import 'package:shared_preferences/shared_preferences.dart';

class QuranStorage {
  static const _darkKey = 'dark_mode';
  static const _bookmarksKey = 'bookmarked_surahs';
  static const _lastReadKey = 'last_read_surah';
  static const _tasbeehKey = 'tasbeeh_count';

  static Future<bool> getDarkMode() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_darkKey) ?? false;
  }

  static Future<void> setDarkMode(bool value) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_darkKey, value);
  }

  static Future<Set<int>> getBookmarkedSurahIds() async {
    final p = await SharedPreferences.getInstance();
    final list = p.getStringList(_bookmarksKey) ?? [];
    return list.map(int.parse).toSet();
  }

  static Future<bool> isBookmarked(int surahId) async {
    final ids = await getBookmarkedSurahIds();
    return ids.contains(surahId);
  }

  static Future<void> toggleBookmark(int surahId) async {
    final p = await SharedPreferences.getInstance();
    final list = p.getStringList(_bookmarksKey) ?? [];
    final set = list.map(int.parse).toSet();
    if (set.contains(surahId)) {
      set.remove(surahId);
    } else {
      set.add(surahId);
    }
    await p.setStringList(
      _bookmarksKey,
      set.map((e) => e.toString()).toList(),
    );
  }

  static Future<void> saveLastRead(int surahId) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_lastReadKey, surahId);
  }

  static Future<int?> getLastRead() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_lastReadKey);
  }

  static Future<int> getTasbeehCount() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_tasbeehKey) ?? 0;
  }

  static Future<void> setTasbeehCount(int value) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_tasbeehKey, value);
  }
}