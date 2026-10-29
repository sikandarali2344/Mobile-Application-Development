import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/quran_models.dart';

class QuranService {
  static const String _base = 'https://api.quran.com/api/v4';
  static int? _urduTranslationId;

  static Future<List<QuranSurahSummary>> fetchSurahs() async {
    final response = await http
        .get(Uri.parse('$_base/chapters?language=en'))
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw Exception('Failed to load Quran chapters: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final chapters = decoded['chapters'] as List<dynamic>;
    return chapters.map((item) {
      final map = item as Map<String, dynamic>;
      final translatedName = map['translated_name'] as Map<String, dynamic>?;
      return QuranSurahSummary(
        id: map['id'] as int,
        name: map['name_simple'] as String,
        arabicName: map['name_arabic'] as String,
        translatedName: translatedName?['name'] as String? ??
            map['name_simple'] as String,
        versesCount: map['verses_count'] as int,
        revelationPlace: map['revelation_place'] as String? ?? 'Unknown',
      );
    }).toList();
  }

  static Future<int?> _findUrduTranslationId() async {
    if (_urduTranslationId != null) return _urduTranslationId;
    try {
      final response = await http
          .get(Uri.parse('$_base/resources/translations?language=ur'))
          .timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) return null;
      final root = jsonDecode(response.body) as Map<String, dynamic>;
      final resources = (root['translations'] as List<dynamic>? ?? []);
      if (resources.isEmpty) return null;
      Map<String, dynamic>? selected;
      for (final item in resources) {
        final resource = item as Map<String, dynamic>;
        final name = (resource['name'] ?? '').toString().toLowerCase();
        final language = (resource['language_name'] ?? '').toString().toLowerCase();
        if (language.contains('urdu') &&
            (name.contains('jalandh') || name.contains('fateh'))) {
          selected = resource;
          break;
        }
        if (selected == null && language.contains('urdu')) selected = resource;
      }
      _urduTranslationId = selected?['id'] as int?;
      return _urduTranslationId;
    } catch (_) {
      return null;
    }
  }

  static Future<List<QuranAyah>> fetchVerses(int chapterId) async {
    final arabicFuture = http
        .get(Uri.parse(
            '$_base/quran/verses/uthmani?chapter_number=$chapterId&limit=300'))
        .timeout(const Duration(seconds: 15));
    final translationId = await _findUrduTranslationId();
    final translationFuture = translationId == null
        ? Future<http.Response?>.value(null)
        : http
            .get(Uri.parse(
                '$_base/verses/by_chapter/$chapterId?language=ur&translations=$translationId&fields=text_uthmani&per_page=300'))
            .timeout(const Duration(seconds: 15))
            .then<http.Response?>((response) => response)
            .catchError((_) => null);

    final arabicResponse = await arabicFuture;
    if (arabicResponse.statusCode != 200) {
      throw Exception('Failed to load Quran verses: ${arabicResponse.statusCode}');
    }
    final arabicRoot = jsonDecode(arabicResponse.body) as Map<String, dynamic>;
    final arabicVerses = arabicRoot['verses'] as List<dynamic>;

    Map<String, String> translationByKey = {};
    final translationResponse = await translationFuture;
    if (translationResponse != null && translationResponse.statusCode == 200) {
      try {
        final root = jsonDecode(translationResponse.body) as Map<String, dynamic>;
        final verses = root['verses'] as List<dynamic>? ?? [];
        for (final item in verses) {
          final verse = item as Map<String, dynamic>;
          final key = verse['verse_key']?.toString();
          final translations = verse['translations'] as List<dynamic>? ?? [];
          final text = translations.isEmpty
              ? ''
              : (translations.first as Map<String, dynamic>)['text']?.toString() ?? '';
          if (key != null && text.isNotEmpty) {
            translationByKey[key] = _cleanTranslation(text);
          }
        }
      } catch (_) {
        // Keep the canonical Arabic available if a translation resource changes.
      }
    }

    final result = <QuranAyah>[];
    for (var i = 0; i < arabicVerses.length; i++) {
      final map = arabicVerses[i] as Map<String, dynamic>;
      final key = map['verse_key']?.toString();
      final parts = key?.split(':') ?? const <String>[];
      final chapter = parts.isNotEmpty ? int.tryParse(parts.first) : null;
      final number = parts.length > 1 ? int.tryParse(parts.last) : null;
      final text = map['text_uthmani']?.toString() ?? '';
      if (chapter != chapterId || number != i + 1 || text.isEmpty) {
        throw FormatException('Unexpected Quran verse data for chapter $chapterId at row ${i + 1}.');
      }
      result.add(QuranAyah(
        number: number!,
        text: text,
        translation: translationByKey[key] ?? '',
      ));
    }
    return result;
  }

  static String _cleanTranslation(String value) => value
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&amp;', '&')
      .trim();
}
