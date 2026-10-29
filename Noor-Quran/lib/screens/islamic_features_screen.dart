import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

import '../models/quran_models.dart';
import '../services/quran_service.dart';

const _green = Color(0xFF0B5D50);
const _gold = Color(0xFFD5AE52);

const _hadithBooks = [
  ('bukhari', 'Sahih al-Bukhari'),
  ('muslim', 'Sahih Muslim'),
  ('abudawud', 'Sunan Abu Dawud'),
  ('tirmidzi', 'Jami at-Tirmidhi'),
  ('nasai', "Sunan an-Nasa'i"),
  ('ibnumajah', 'Sunan Ibn Majah'),
  ('malik', 'Muwatta Malik'),
  ('ahmad', 'Musnad Ahmad'),
  ('darimi', 'Sunan ad-Darimi'),
];

Map<String, dynamic> _fallbackHadithPreview(String bookId) {
  final name = _hadithBooks
      .firstWhere(
        (book) => book.$1 == bookId,
        orElse: () => ('bukhari', 'Sahih al-Bukhari'),
      )
      .$2;

  return {
    'book': bookId,
    'book_name': name,
    'number': 1,
    'arab': 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ',
    'id': 'Hadits ini adalah contoh ringkasan lokal saat layanan hadits online tidak tersedia.',
    'reference': 'Hadith collection preview · $name',
  };
}

List<Map<String, dynamic>> _fallbackHadithPage(String bookId, int start) {
  final bookName = _hadithBooks
      .firstWhere(
        (book) => book.$1 == bookId,
        orElse: () => ('bukhari', 'Sahih al-Bukhari'),
      )
      .$2;

  return List.generate(
    5,
    (index) => {
      'book': bookId,
      'book_name': bookName,
      'number': start + index,
      'arab': 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ',
      'id': 'Contoh judul hadits lokal untuk $bookName.',
      'reference': 'Local preview • ${start + index}',
    },
  );
}

const _reciters = [
  ('Alafasy_128kbps', 'Mishary Rashid Alafasy'),
  ('Abdul_Basit_Murattal_192kbps', 'Abdul Basit'),
  ('Hani_Rifai_192kbps', 'Hani ar-Rifai'),
  ('MaherAlMuaiqly128kbps', 'Maher al-Muaiqly'),
];

class IslamicFeaturesScreen extends StatefulWidget {
  const IslamicFeaturesScreen({super.key});
  @override
  State<IslamicFeaturesScreen> createState() => _IslamicFeaturesScreenState();
}

class _IslamicFeaturesScreenState extends State<IslamicFeaturesScreen> {
  final AudioPlayer _quranAudio = AudioPlayer();
  String _city = 'Karachi';
  Map<String, dynamic>? _timings;
  bool _prayerLoading = false;
  String? _prayerError;
  String _hadithBook = 'bukhari';
  Map<String, dynamic>? _hadith;
  bool _hadithLoading = false;
  List<QuranSurahSummary> _surahs = [];
  List<QuranAyah> _selectedVerses = [];
  int _selectedSurahId = 1;
  String _selectedReciter = _reciters.first.$1;
  String? _loadedReciter;
  int? _loadedSurahId;
  bool _quranLoading = true;
  bool _audioLoading = false;
  String? _quranError;
  String? _audioError;
  int _tasbeeh = 0;
  int _duaIndex = 0;

  static const _duas = [
    {
      'title': 'Before sleeping',
      'arabic': 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
      'meaning': 'In Your name, O Allah, I die and I live.',
      'reference': 'Sahih al-Bukhari 6324',
    },
    {
      'title': 'When leaving home',
      'arabic': 'بِسْمِ اللَّهِ تَوَكَّلْتُ عَلَى اللَّهِ لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
      'meaning': 'In the name of Allah; I put my trust in Allah. There is no power or strength except through Allah.',
      'reference': 'Sunan Abi Dawud 5095',
    },
    {
      'title': 'Seeking knowledge',
      'arabic': 'رَبِّ زِدْنِي عِلْمًا',
      'meaning': 'My Lord, increase me in knowledge.',
      'reference': 'Quran 20:114',
    },
    {
      'title': 'For forgiveness',
      'arabic': 'رَبَّنَا ظَلَمْنَا أَنْفُسَنَا وَإِنْ لَمْ تَغْفِرْ لَنَا وَتَرْحَمْنَا لَنَكُونَنَّ مِنَ الْخَاسِرِينَ',
      'meaning': 'Our Lord, we have wronged ourselves. If You do not forgive us and have mercy upon us, we will surely be among the losers.',
      'reference': 'Quran 7:23',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadPrayerTimes();
    _loadHadith();
    _loadSurahs();
  }

  @override
  void dispose() {
    _quranAudio.dispose();
    super.dispose();
  }

  Future<void> _loadSurahs() async {
    try {
      final surahs = await QuranService.fetchSurahs();
      if (!mounted) return;
      setState(() {
        _surahs = surahs;
        _quranLoading = false;
      });
      await _loadSelectedSurah(_selectedSurahId);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _quranLoading = false;
        _quranError = 'Could not load Quran chapters. Check your connection.';
      });
    }
  }

  Future<void> _loadSelectedSurah(int surahId) async {
    setState(() {
      _selectedSurahId = surahId;
      _quranLoading = true;
      _quranError = null;
      _loadedReciter = null;
      _loadedSurahId = null;
      _audioError = null;
    });
    await _quranAudio.stop();
    try {
      final verses = await QuranService.fetchVerses(surahId);
      if (!mounted) return;
      setState(() {
        _selectedVerses = verses;
        _quranLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _selectedVerses = [];
        _quranLoading = false;
        _quranError = 'Could not load ayat for this surah. Try again online.';
      });
    }
  }

  Future<void> _playSelectedSurah() async {
    if (_selectedVerses.isEmpty) return;
    if (_audioLoading) return;
    if (_quranAudio.playing) {
      await _quranAudio.pause();
      return;
    }

    setState(() {
      _audioLoading = true;
      _audioError = null;
    });
    try {
      if (_loadedReciter != _selectedReciter ||
          _loadedSurahId != _selectedSurahId ||
          _quranAudio.processingState == ProcessingState.idle ||
          _quranAudio.processingState == ProcessingState.completed) {
        final surah = _selectedSurahId.toString().padLeft(3, '0');
        final sources = _selectedVerses.map((verse) {
          final ayah = verse.number.toString().padLeft(3, '0');
          return AudioSource.uri(
            Uri.parse(
              'https://everyayah.com/data/$_selectedReciter/$surah$ayah.mp3',
            ),
          );
        }).toList();
        await _quranAudio.setAudioSources(sources);
        _loadedReciter = _selectedReciter;
        _loadedSurahId = _selectedSurahId;
      }
      if (!mounted) return;
      setState(() => _audioLoading = false);
      await _quranAudio.play();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _audioLoading = false;
        _audioError = 'Playback failed. Tap Listen to retry.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Recitation could not start. Check your connection and tap Listen again. ($error)',
          ),
        ),
      );
    }
  }

  Future<void> _showAllAyahs() async {
    final surah = _surahs
        .where((item) => item.id == _selectedSurahId)
        .firstOrNull;
    if (surah == null || _selectedVerses.isEmpty) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * .82,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 12, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${surah.name} · ${surah.arabicName}',
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: _selectedVerses.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => _ayahTile(
                    _selectedVerses[index],
                    index,
                    dark: Theme.of(context).brightness == Brightness.dark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadPrayerTimes() async {
    setState(() {
      _prayerLoading = true;
      _prayerError = null;
    });
    try {
      final city = Uri.encodeComponent(_city);
      final uri = Uri.parse(
        'https://api.aladhan.com/v1/timingsByCity?city=$city&country=Pakistan&method=1',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) {
        throw Exception('Prayer times service unavailable');
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        _timings = Map<String, dynamic>.from(data['timings'] as Map);
        _prayerLoading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _prayerLoading = false;
          _prayerError =
              'Could not load live timings. Check your internet connection.';
        });
      }
    }
  }

  Future<void> _loadHadith() async {
    setState(() {
      _hadithLoading = true;
    });
    try {
      final uri = Uri.parse(
        'https://api.hadith.gading.dev/books/$_hadithBook?range=1-1',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) throw Exception();
      final root = jsonDecode(response.body) as Map<String, dynamic>;
      final data = root['data'] as Map<String, dynamic>? ?? const {};
      final hadiths = data['hadiths'] as List<dynamic>? ?? const [];
      if (!mounted) return;
      setState(() {
        _hadith = hadiths.isEmpty
            ? _fallbackHadithPreview(_hadithBook)
            : Map<String, dynamic>.from(hadiths.first as Map);
        _hadithLoading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _hadith = _fallbackHadithPreview(_hadithBook);
          _hadithLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fg = dark ? Colors.white : const Color(0xFF18332F);
    final muted = dark ? Colors.white70 : const Color(0xFF687873);
    return Scaffold(
      backgroundColor: dark ? const Color(0xFF101B1A) : const Color(0xFFF7F5EC),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: _green.withValues(alpha: dark ? .28 : .1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.nightlight_round,
                            color: _gold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Assalamu Alaikum',
                              style: TextStyle(
                                color: muted,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Your Islamic Companion',
                              style: TextStyle(
                                color: fg,
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'A little guidance for every day.',
                      style: TextStyle(color: muted, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    _prayerCard(dark),
                    const SizedBox(height: 24),
                    _sectionHeading('Quran & recitation', fg),
                    const SizedBox(height: 12),
                    _quranCard(dark),
                    const SizedBox(height: 24),
                    _sectionHeading('Explore your Deen', fg),
                    const SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.35,
                      children: [
                        _featureTile(
                          Icons.menu_book_rounded,
                          'Hadith library',
                          'Browse all collections',
                          () => _showHadithDialog(),
                          dark,
                        ),
                        _featureTile(
                          Icons.explore_rounded,
                          'Qibla direction',
                          'Direction guide',
                          () => _showQiblaDialog(),
                          dark,
                        ),
                        _featureTile(
                          Icons.volunteer_activism_rounded,
                          'Daily duas',
                          'References included',
                          () => _showDuaDialog(),
                          dark,
                        ),
                        _featureTile(
                          Icons.spa_rounded,
                          'Digital Tasbeeh',
                          'Tap to count',
                          () => _showTasbeehDialog(),
                          dark,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _sectionHeading('Hadith collection preview', fg),
                    const SizedBox(height: 12),
                    _hadithCard(dark),
                    const SizedBox(height: 24),
                    _sectionHeading('Daily dua', fg),
                    const SizedBox(height: 12),
                    _duaCard(dark),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeading(String title, Color color) => Text(
    title,
    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: color),
  );

  Widget _quranCard(bool dark) {
    final foreground = dark ? Colors.white : const Color(0xFF18332F);
    final muted = dark ? Colors.white70 : const Color(0xFF687873);
    final selectedSurah = _surahs
        .where((surah) => surah.id == _selectedSurahId)
        .firstOrNull;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF1C2A28) : const Color(0xFFFFFDF7),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _gold.withValues(alpha: .4)),
        boxShadow: [
          BoxShadow(
            color: _green.withValues(alpha: dark ? .08 : .06),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _green.withValues(alpha: dark ? .3 : .1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.headphones_rounded,
                  color: dark ? const Color(0xFF8CC9B6) : _green,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Listen and read Quran',
                      style: TextStyle(
                        color: foreground,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Choose a surah and your favourite reciter',
                      style: TextStyle(color: muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_quranLoading && _surahs.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(color: _green),
              ),
            )
          else if (_quranError != null && _surahs.isEmpty)
            Text(_quranError!, style: TextStyle(color: muted))
          else ...[
            DropdownButtonFormField<int>(
              initialValue: _selectedSurahId,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Surah',
                prefixIcon: const Icon(Icons.menu_book_rounded),
                filled: true,
                fillColor: dark
                    ? Colors.white.withValues(alpha: .05)
                    : const Color(0xFFF7F5EC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
              items: _surahs
                  .map(
                    (surah) => DropdownMenuItem(
                      value: surah.id,
                      child: Text(
                        '${surah.id}. ${surah.name} · ${surah.arabicName}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: _quranLoading
                  ? null
                  : (surahId) {
                      if (surahId != null) _loadSelectedSurah(surahId);
                    },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedReciter,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Reciter',
                prefixIcon: const Icon(Icons.record_voice_over_rounded),
                filled: true,
                fillColor: dark
                    ? Colors.white.withValues(alpha: .05)
                    : const Color(0xFFF7F5EC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
              items: _reciters
                  .map(
                    (reciter) => DropdownMenuItem(
                      value: reciter.$1,
                      child: Text(reciter.$2),
                    ),
                  )
                  .toList(),
              onChanged: (reciter) async {
                if (reciter == null) return;
                await _quranAudio.stop();
                if (mounted) {
                  setState(() {
                    _selectedReciter = reciter;
                    _loadedReciter = null;
                    _loadedSurahId = null;
                    _audioError = null;
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            if (_quranLoading)
              const LinearProgressIndicator(color: _green)
            else if (_quranError != null)
              Text(_quranError!, style: TextStyle(color: muted))
            else if (_selectedVerses.isNotEmpty) ...[
              if (_audioError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _audioError!,
                    style: TextStyle(
                      color: dark
                          ? Colors.orange.shade200
                          : Colors.red.shade700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ..._selectedVerses
                  .take(2)
                  .map((ayah) => _ayahTile(ayah, ayah.number - 1, dark: dark)),
              if (_selectedVerses.length > 2)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _showAllAyahs,
                    child: Text('Read all ${_selectedVerses.length} ayat'),
                  ),
                ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    selectedSurah == null
                        ? 'Full surah recitation'
                        : '${selectedSurah.translatedName} · ${selectedSurah.versesCount} ayat',
                    style: TextStyle(color: muted, fontSize: 12),
                  ),
                ),
                StreamBuilder<PlayerState>(
                  stream: _quranAudio.playerStateStream,
                  builder: (context, snapshot) {
                    final playing = snapshot.data?.playing ?? false;
                    return FilledButton.icon(
                      onPressed: _quranLoading || _audioLoading
                          ? null
                          : _playSelectedSurah,
                      icon: _audioLoading
                          ? const SizedBox(
                              width: 17,
                              height: 17,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              playing
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                            ),
                      label: Text(
                        _audioLoading
                            ? 'Loading'
                            : playing
                            ? 'Pause'
                            : 'Listen',
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _ayahTile(QuranAyah ayah, int index, {required bool dark}) {
    final accent = dark ? const Color(0xFF8CC9B6) : _green;
    final foreground = dark ? Colors.white : const Color(0xFF18332F);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: dark ? Colors.white.withValues(alpha: .04) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: CircleAvatar(
              radius: 14,
              backgroundColor: accent.withValues(alpha: .12),
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 9),
          Text(
            ayah.text,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: accent,
              fontSize: 21,
              height: 1.8,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (ayah.translation.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              ayah.translation,
              style: TextStyle(
                color: foreground.withValues(alpha: .8),
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _prayerCard(bool dark) {
    final times = _timings;
    const keys = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF084B43), Color(0xFF117567)],
        ),
        boxShadow: [
          BoxShadow(
            color: _green.withValues(alpha: .22),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.mosque_rounded, color: _gold, size: 23),
              const SizedBox(width: 9),
              const Expanded(
                child: Text(
                  'Prayer times',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              DropdownButton<String>(
                value: _city,
                dropdownColor: _green,
                underline: const SizedBox(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                iconEnabledColor: _gold,
                items: const [
                  DropdownMenuItem(
                    value: 'Nawabshah',
                    child: Text('Nawabshah'),
                  ),
                  DropdownMenuItem(value: 'Karachi', child: Text('Karachi')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _city = value);
                    _loadPrayerTimes();
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_prayerLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: _gold,
                    strokeWidth: 2,
                  ),
                ),
              ),
            )
          else if (_prayerError != null)
            Text(_prayerError!, style: const TextStyle(color: Colors.white70))
          else if (times != null)
            Row(
              children: keys
                  .map(
                    (key) => Expanded(
                      child: Column(
                        children: [
                          Text(
                            key,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 7),
                          FittedBox(
                            child: Text(
                              (times[key] ?? '--').toString().split(' ').first,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            )
          else
            const Text(
              'Prayer times load when connected to the internet.',
              style: TextStyle(color: Colors.white70),
            ),
          const SizedBox(height: 10),
          const Divider(color: Colors.white24),
          Row(
            children: [
              const Icon(Icons.wb_twilight_rounded, color: _gold, size: 18),
              const SizedBox(width: 7),
              const Expanded(
                child: Text(
                  'Timings are calculated for the selected city.',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ),
              IconButton(
                onPressed: _loadPrayerTimes,
                tooltip: 'Refresh prayer times',
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _featureTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback tap,
    bool dark,
  ) {
    final foreground = dark ? Colors.white : const Color(0xFF18332F);
    return Material(
      color: dark ? const Color(0xFF1C2A28) : const Color(0xFFFFFDF7),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: tap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _gold.withValues(alpha: dark ? .28 : .4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: _green.withValues(alpha: dark ? .3 : .1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: dark ? const Color(0xFF8CC9B6) : _green,
                  size: 24,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                title,
                style: TextStyle(
                  color: foreground,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  color: dark ? Colors.white60 : const Color(0xFF687873),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hadithCard(bool dark) {
    final textColor = Theme.of(context).hintColor;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF1C2A28) : const Color(0xFFFFFDF7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _gold.withValues(alpha: .4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_stories_rounded, color: _gold),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Hadith collection preview',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              DropdownButton<String>(
                value: _hadithBook,
                items: _hadithBooks
                    .map(
                      (book) => DropdownMenuItem(
                        value: book.$1,
                        child: Text(book.$2.split(' ').last),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _hadithBook = value);
                    _loadHadith();
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_hadithLoading)
            const LinearProgressIndicator()
          else if (_hadith != null) ...[
            Text(
              (_hadith!['arab'] ?? '').toString(),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: const TextStyle(fontSize: 23, height: 1.8),
            ),
            const SizedBox(height: 8),
            Text(
              (_hadith!['id'] ?? '').toString(),
              style: TextStyle(color: textColor, fontSize: 12),
            ),
            const SizedBox(height: 5),
            Text(
              'Collection: ${_hadithBook.toUpperCase()}. The service may return an Indonesian translation; verify Arabic, wording, grading and numbering against a trusted edition.',
              style: TextStyle(color: textColor, fontSize: 11),
            ),
          ] else
            const Text(
              'Could not fetch the selected collection. Try again when online.',
            ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _loadHadith,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _duaCard(bool dark) {
    final dua = _duas[_duaIndex];
    final textColor = dark ? Colors.white : const Color(0xFF18332F);
    final accent = dark ? const Color(0xFF8CC9B6) : _green;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF1C2A28) : const Color(0xFFFFFDF7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _gold.withValues(alpha: .45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dua['title']!,
            style: TextStyle(fontWeight: FontWeight.w800, color: accent),
          ),
          const SizedBox(height: 10),
          Text(
            dua['arabic']!,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 25, height: 1.8, color: accent),
          ),
          const SizedBox(height: 8),
          Text(dua['meaning']!, style: TextStyle(color: textColor)),
          const SizedBox(height: 8),
          Text(
            dua['reference']!,
            style: TextStyle(
              color: dark ? Colors.white60 : const Color(0xFF687873),
              fontSize: 12,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () =>
                  setState(() => _duaIndex = (_duaIndex + 1) % _duas.length),
              icon: const Icon(Icons.navigate_next),
              label: const Text('Next dua'),
            ),
          ),
        ],
      ),
    );
  }

  void _showHadithDialog() => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _HadithLibrarySheet(),
  );

  double _qiblaBearingDegrees() {
    // Great-circle initial bearing from the selected city to the Kaaba.
    const kaabaLat = 21.4225;
    const kaabaLon = 39.8262;
    final cityLat = _city == 'Karachi' ? 24.8607 : 26.2442;
    final cityLon = _city == 'Karachi' ? 67.0011 : 68.4100;
    final lat1 = cityLat * math.pi / 180;
    final lat2 = kaabaLat * math.pi / 180;
    final deltaLon = (kaabaLon - cityLon) * math.pi / 180;
    final y = math.sin(deltaLon) * math.cos(lat2);
    final x =
        math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(deltaLon);
    return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
  }

  void _showQiblaDialog() {
    final bearing = _qiblaBearingDegrees();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Qibla direction'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.rotate(
              angle: bearing * math.pi / 180,
              child: const Icon(
                Icons.navigation_rounded,
                size: 84,
                color: _green,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Approximate direction for $_city: ${bearing.toStringAsFixed(1)}° from true north.',
            ),
            const SizedBox(height: 8),
            const Text(
              'Calculated from the city centre. This is not a live compass; nearby buildings, magnetic interference and exact location can affect alignment.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDuaDialog() => showModalBottomSheet(
    context: context,
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily duas',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ..._duas.map(
              (d) => ListTile(
                title: Text(d['title']!),
                subtitle: Text('${d['meaning']}\n${d['reference']}'),
                isThreeLine: true,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  void _showTasbeehDialog() => showDialog(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setLocal) => AlertDialog(
        title: const Text('Digital Tasbeeh'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'سُبْحَانَ اللَّهِ',
              style: TextStyle(fontSize: 28, color: _green),
            ),
            const SizedBox(height: 10),
            Text(
              '$_tasbeeh',
              style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
            ),
            const Text('Count your remembrance at your own pace.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _tasbeeh = 0);
              setLocal(() {});
            },
            child: const Text('Reset'),
          ),
          FilledButton.icon(
            onPressed: () {
              setState(() => _tasbeeh++);
              setLocal(() {});
            },
            icon: const Icon(Icons.add),
            label: const Text('Count'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    ),
  );
}

class _HadithLibrarySheet extends StatefulWidget {
  const _HadithLibrarySheet();

  @override
  State<_HadithLibrarySheet> createState() => _HadithLibrarySheetState();
}

class _HadithLibrarySheetState extends State<_HadithLibrarySheet> {
  static const _pageSize = 10;

  (String, String)? _selectedBook;
  List<Map<String, dynamic>> _hadiths = [];
  int _rangeStart = 1;
  int? _available;
  bool _loading = false;
  String? _error;

  Future<void> _openBook((String, String) book) async {
    setState(() {
      _selectedBook = book;
      _rangeStart = 1;
      _hadiths = [];
      _available = null;
    });
    await _loadPage(1);
  }

  Future<void> _loadPage(int start) async {
    final book = _selectedBook;
    if (book == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final end = start + _pageSize - 1;
      final uri = Uri.parse(
        'https://api.hadith.gading.dev/books/${book.$1}?range=$start-$end',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) {
        throw Exception('Hadith service returned ${response.statusCode}.');
      }
      final root = jsonDecode(response.body) as Map<String, dynamic>;
      final data = root['data'] as Map<String, dynamic>? ?? const {};
      final items = data['hadiths'] as List<dynamic>? ?? const [];
      final available = int.tryParse(data['available']?.toString() ?? '');
      if (!mounted) return;
      setState(() {
        _rangeStart = start;
        _available = available;
        _hadiths = items
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
        _loading = false;
        if (items.isEmpty) {
          _error = 'No entries found in this range.';
          _hadiths = _fallbackHadithPage(book.$1, start);
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _hadiths = _fallbackHadithPage(book.$1, start);
        _error =
            'Could not load this collection. Check your connection and retry.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final foreground = dark ? Colors.white : const Color(0xFF18332F);
    final muted = dark ? Colors.white70 : const Color(0xFF687873);
    final book = _selectedBook;

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .9,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 12, 10),
              child: Row(
                children: [
                  if (book != null)
                    IconButton(
                      onPressed: () => setState(() {
                        _selectedBook = null;
                        _hadiths = [];
                        _available = null;
                        _error = null;
                      }),
                      icon: const Icon(Icons.arrow_back_rounded),
                    )
                  else
                    const Icon(Icons.auto_stories_rounded, color: _gold),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book?.$2 ?? 'Hadith library',
                          style: TextStyle(
                            color: foreground,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          book == null
                              ? 'Choose a collection to browse'
                              : _hadiths.isEmpty
                              ? 'Browse entries'
                              : 'Entries $_rangeStart–${_rangeStart + _hadiths.length - 1}',
                          style: TextStyle(color: muted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            if (book == null)
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _hadithBooks.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 9),
                  itemBuilder: (context, index) {
                    final item = _hadithBooks[index];
                    return Material(
                      color: dark
                          ? const Color(0xFF1C2A28)
                          : const Color(0xFFFFFDF7),
                      borderRadius: BorderRadius.circular(16),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: _gold.withValues(alpha: .35)),
                        ),
                        leading: CircleAvatar(
                          backgroundColor: _green.withValues(
                            alpha: dark ? .3 : .1,
                          ),
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: _green,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        title: Text(
                          item.$2,
                          style: TextStyle(
                            color: foreground,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          'Open collection and browse hadith',
                          style: TextStyle(color: muted, fontSize: 12),
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => _openBook(item),
                      ),
                    );
                  },
                ),
              )
            else ...[
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(color: _green),
                      )
                    : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.cloud_off_rounded,
                                color: muted,
                                size: 36,
                              ),
                              const SizedBox(height: 12),
                              Text(_error!, textAlign: TextAlign.center),
                              const SizedBox(height: 8),
                              FilledButton.icon(
                                onPressed: () => _loadPage(_rangeStart),
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('Try again'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                        itemCount: _hadiths.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = _hadiths[index];
                          final arabic = (item['arab'] ?? '').toString();
                          final translation = (item['idn'] ?? '').toString();
                          final reference = (item['number'] ?? item['id'] ?? '')
                              .toString();
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: dark
                                  ? const Color(0xFF1C2A28)
                                  : const Color(0xFFFFFDF7),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: _gold.withValues(alpha: .3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  reference.isEmpty
                                      ? 'Hadith ${_rangeStart + index}'
                                      : 'Hadith $reference',
                                  style: TextStyle(
                                    color: muted,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (arabic.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Text(
                                    arabic,
                                    textDirection: TextDirection.rtl,
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      color: dark
                                          ? const Color(0xFF8CC9B6)
                                          : _green,
                                      fontSize: 21,
                                      height: 1.8,
                                    ),
                                  ),
                                ],
                                if (translation.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Text(
                                    translation,
                                    style: TextStyle(
                                      color: foreground,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    'Translation provided by the online source; verify against a trusted edition.',
                                    style: TextStyle(
                                      color: muted,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                child: Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _loading || _rangeStart <= 1
                          ? null
                          : () => _loadPage(_rangeStart - _pageSize),
                      icon: const Icon(Icons.chevron_left_rounded),
                      label: const Text('Previous'),
                    ),
                    const Spacer(),
                    Text(
                      'Page ${((_rangeStart - 1) ~/ _pageSize) + 1}',
                      style: TextStyle(color: muted),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed:
                          _loading ||
                              (_available != null
                                  ? _rangeStart + _hadiths.length - 1 >=
                                        _available!
                                  : _hadiths.length < _pageSize)
                          ? null
                          : () => _loadPage(_rangeStart + _pageSize),
                      icon: const Icon(Icons.chevron_right_rounded),
                      label: const Text('Next'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
