import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';

import '../models/quran_models.dart';
import '../services/quran_service.dart';
import '../services/quran_storage.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_background.dart';

class SurahDetailScreen extends StatefulWidget {
  const SurahDetailScreen({super.key, required this.surah});
  final QuranSurahSummary surah;

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  static const _reciters = [
    ('Alafasy_128kbps', 'Mishary Rashid Alafasy'),
    ('Abdul_Basit_Murattal_192kbps', 'Abdul Basit'),
    ('Hani_Rifai_192kbps', 'Hani ar-Rifai'),
    ('MaherAlMuaiqly128kbps', 'Maher al-Muaiqly'),
  ];

  final _audio = AudioPlayer();
  final _pageController = PageController();
  late final StreamSubscription<PlayerState> _stateSub;
  late final StreamSubscription<int?> _indexSub;

  static const double _minFont = 18;
  static const double _maxFont = 40;
  static const gold = Color(0xFFD4AF37);
  static const emerald = Color(0xFF0F766E);
  static const deepTeal = Color(0xFF0A4A47);

  List<QuranAyah> _verses = [];
  static const _ayahsPerPage = 10;
  double _fontSize = 26;
  bool _loading = true;
  bool _bookmarked = false;
  bool _playing = false;
  bool _audioLoading = false;
  String _selectedReciter = 'Alafasy_128kbps';
  String? _loadedReciter;
  int _currentAyah = -1;
  bool _showTranslation = true;

  @override
  void initState() {
    super.initState();
    _stateSub = _audio.playerStateStream.listen((s) {
      if (!mounted) return;
      final playing =
          s.playing && s.processingState != ProcessingState.completed;
      if (_playing != playing) {
        setState(() => _playing = playing);
      }
      if (s.processingState == ProcessingState.completed) {
        if (mounted) setState(() => _currentAyah = -1);
      } else if (playing) {
        _startPositionSync();
      }
    });
    _indexSub = _audio.currentIndexStream.listen((index) {
      if (!mounted || index == null || index < 0 || index >= _verses.length) {
        return;
      }
      _setPlaybackPosition(index);
    });
    _load();
  }

  @override
  void dispose() {
    _stateSub.cancel();
    _indexSub.cancel();
    _audio.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final verses = await QuranService.fetchVerses(widget.surah.id);
      final bm = await QuranStorage.isBookmarked(widget.surah.id);
      if (!mounted) return;
      setState(() {
        _verses = verses;
        _bookmarked = bm;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _startPositionSync() {
    // Ayah highlighting is driven only by the playlist's current index.
    // Word-level highlighting is deliberately disabled unless verified timing
    // segments for this exact recitation are available.
  }

  void _setPlaybackPosition(int ayahIndex) {
    if (!mounted || ayahIndex == _currentAyah) return;
    setState(() => _currentAyah = ayahIndex);
    final page = ayahIndex ~/ _ayahsPerPage;
    if (_pageController.hasClients &&
        (_pageController.page?.round() ?? -1) != page) {
      _pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> _togglePlay() async {
    if (_playing) {
      await _audio.pause();
      return;
    }
    if (_verses.isEmpty || _audioLoading) return;
    setState(() => _audioLoading = true);
    try {
      // Use a separate verified verse audio file for each ayah. This avoids
      // estimating the displayed ayah from total-surah duration, which can drift.
      if (_loadedReciter != _selectedReciter ||
          _audio.processingState == ProcessingState.idle ||
          _audio.processingState == ProcessingState.completed) {
        final surah = widget.surah.id.toString().padLeft(3, '0');
        final sources = _verses.map((verse) {
          final ayah = verse.number.toString().padLeft(3, '0');
          return AudioSource.uri(
            Uri.parse(
              'https://everyayah.com/data/$_selectedReciter/$surah$ayah.mp3',
            ),
          );
        }).toList();
        await _audio.setAudioSources(sources);
        _loadedReciter = _selectedReciter;
      }
      if (!mounted) return;
      setState(() => _audioLoading = false);
      await _audio.play();
    } catch (error) {
      if (!mounted) return;
      setState(() => _audioLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Recitation could not start. Check your connection and try again. ($error)',
          ),
        ),
      );
    }
  }

  Future<void> _selectReciter(String? reciter) async {
    if (reciter == null || reciter == _selectedReciter) return;
    await _audio.stop();
    if (!mounted) return;
    setState(() {
      _selectedReciter = reciter;
      _loadedReciter = null;
      _currentAyah = -1;
      _audioLoading = false;
    });
  }

  Future<void> _showReciterPicker() async {
    final reciter = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF123F3A)
          : const Color(0xFFFFFDF7),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white30 : Colors.black26,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Choose a reciter',
                  style: TextStyle(
                    color: isDark ? Colors.white : deepTeal,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Select whose recitation you want to hear',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                ..._reciters.map((reciter) {
                  final selected = reciter.$1 == _selectedReciter;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    leading: CircleAvatar(
                      backgroundColor: selected
                          ? emerald.withValues(alpha: .15)
                          : (isDark ? Colors.white10 : Colors.black12),
                      child: Icon(
                        Icons.record_voice_over_rounded,
                        color: selected
                            ? (isDark ? const Color(0xFF8CC9B6) : emerald)
                            : (isDark ? Colors.white70 : Colors.black54),
                      ),
                    ),
                    title: Text(
                      reciter.$2,
                      style: TextStyle(
                        color: isDark ? Colors.white : deepTeal,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                    trailing: selected
                        ? const Icon(Icons.check_circle_rounded, color: emerald)
                        : const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.pop(sheetContext, reciter.$1),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
    await _selectReciter(reciter);
  }

  Future<void> _toggleBookmark() async {
    await QuranStorage.toggleBookmark(widget.surah.id);
    final bm = await QuranStorage.isBookmarked(widget.surah.id);
    if (!mounted) return;
    setState(() => _bookmarked = bm);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedBackground()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, c) {
                final maxW = c.maxWidth > 560 ? 560.0 : c.maxWidth;
                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxW),
                    child: Column(
                      children: [
                        _topBar(isDark),
                        _heroCard(isDark),
                        const SizedBox(height: 12),
                        _fontControls(isDark),
                        const SizedBox(height: 8),
                        Expanded(
                          child: _loading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: AppTheme.gold,
                                  ),
                                )
                              : _ayahList(isDark),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBar(bool isDark) {
    final controlColor = Colors.white.withValues(alpha: isDark ? 0.12 : 0.22);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: controlColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  widget.surah.name,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  widget.surah.translatedName,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () =>
                setState(() => _showTranslation = !_showTranslation),
            icon: Icon(
              _showTranslation
                  ? Icons.translate_rounded
                  : Icons.translate_outlined,
              color: Colors.white,
            ),
            style: IconButton.styleFrom(
              backgroundColor: controlColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroCard(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? const [Color(0xFF092F31), Color(0xFF0F625A)]
                : const [Color(0xFF0A4A47), Color(0xFF0F766E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: gold.withValues(alpha: 0.45)),
          boxShadow: [
            BoxShadow(
              color: emerald.withValues(alpha: 0.35),
              blurRadius: 26,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              top: -44,
              right: -28,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            Positioned(
              top: -22,
              right: -6,
              child: Container(
                width: 106,
                height: 106,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: gold.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'SURAH ${widget.surah.id.toString().padLeft(3, '0')}',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFE7D28A),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.auto_awesome_rounded,
                        color: Color(0xFFE7D28A),
                        size: 19,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.surah.arabicName,
                    style: GoogleFonts.amiri(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${widget.surah.versesCount} verses  •  ${widget.surah.revelationPlace}',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 13),
                  Material(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: _showReciterPicker,
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 9,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: gold.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.graphic_eq_rounded,
                                color: Color(0xFFE7D28A),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'RECITER',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white60,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  Text(
                                    _reciters
                                        .firstWhere(
                                          (reciter) =>
                                              reciter.$1 == _selectedReciter,
                                        )
                                        .$2,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Color(0xFFE7D28A),
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _chip(
                        _audioLoading
                            ? 'Loading'
                            : _playing
                            ? 'Pause'
                            : 'Listen',
                        _audioLoading
                            ? Icons.hourglass_top_rounded
                            : _playing
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        _togglePlay,
                        emphasized: true,
                      ),
                      const SizedBox(width: 10),
                      _chip(
                        _bookmarked ? 'Saved' : 'Bookmark',
                        _bookmarked
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        _toggleBookmark,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(
    String label,
    IconData icon,
    VoidCallback onTap, {
    bool emphasized = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: emphasized
              ? const Color(0xFFF6E9BC)
              : Colors.white.withValues(alpha: 0.12),
          border: emphasized
              ? null
              : Border.all(color: Colors.white.withValues(alpha: 0.18)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: emphasized ? deepTeal : Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: emphasized ? deepTeal : Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fontControls(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF102C2C).withValues(alpha: 0.88)
            : Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : deepTeal.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _fontSize <= _minFont
                ? null
                : () => setState(() => _fontSize -= 1),
            icon: const Icon(Icons.text_decrease_rounded),
            color: isDark ? Colors.white70 : deepTeal,
          ),
          Expanded(
            child: Slider(
              min: _minFont,
              max: _maxFont,
              divisions: (_maxFont - _minFont).toInt(),
              value: _fontSize,
              label: '${_fontSize.round()}',
              activeColor: isDark ? AppTheme.gold : emerald,
              inactiveColor: isDark
                  ? Colors.white24
                  : deepTeal.withValues(alpha: 0.14),
              onChanged: (v) => setState(() => _fontSize = v),
            ),
          ),
          IconButton(
            onPressed: _fontSize >= _maxFont
                ? null
                : () => setState(() => _fontSize += 1),
            icon: const Icon(Icons.text_increase_rounded),
            color: isDark ? Colors.white70 : deepTeal,
          ),
        ],
      ),
    );
  }

  Widget _ayahList(bool isDark) {
    return ScrollConfiguration(
      behavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
        },
      ),
      child: PageView.builder(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        itemCount: (_verses.length / _ayahsPerPage).ceil(),
        itemBuilder: (_, page) {
          final start = page * _ayahsPerPage;
          final end = (start + _ayahsPerPage).clamp(0, _verses.length);
          return Padding(
            padding: const EdgeInsets.fromLTRB(10, 2, 10, 18),
            child: _quranPage(_verses.sublist(start, end), start, isDark),
          );
        },
      ),
    );
  }

  Widget _quranPage(List<QuranAyah> verses, int startIndex, bool isDark) {
    final normalTextColor = isDark ? Colors.white : deepTeal;

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF102E2C).withValues(alpha: 0.96)
            : const Color(0xFFFFFCF4).withValues(alpha: 0.98),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? gold.withValues(alpha: 0.3)
              : gold.withValues(alpha: 0.55),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _pageOrnament(isDark, '${(startIndex ~/ _ayahsPerPage) + 1}'),
            const SizedBox(height: 12),
            Directionality(
              textDirection: TextDirection.rtl,
              child: RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  style: TextStyle(
                    color: normalTextColor,
                    fontSize: _fontSize,
                    height: 2.05,
                    fontWeight: FontWeight.w500,
                    fontFamily: GoogleFonts.amiri().fontFamily,
                  ),
                  children: [
                    for (
                      var localIndex = 0;
                      localIndex < verses.length;
                      localIndex++
                    )
                      _ayahSpan(
                        verses[localIndex],
                        startIndex + localIndex,
                        normalTextColor,
                        isDark,
                      ),
                  ],
                ),
              ),
            ),
            if (_showTranslation) ...[
              const SizedBox(height: 18),
              const Divider(color: gold),
              for (final verse in verses)
                if (verse.translation.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        '${verse.number}. ${verse.translation}',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: normalTextColor.withValues(alpha: 0.9),
                          fontSize: 16,
                          height: 1.8,
                        ),
                      ),
                    ),
                  )
                else if (verse == verses.first)
                  const Text(
                    'Urdu translation is unavailable offline or from the current service.',
                    style: TextStyle(fontSize: 12),
                  ),
            ],
            const SizedBox(height: 12),
            _pageOrnament(isDark, '${(startIndex ~/ _ayahsPerPage) + 1}'),
          ],
        ),
      ),
    );
  }

  Widget _pageOrnament(bool isDark, String pageNumber) {
    final color = isDark
        ? gold.withValues(alpha: 0.8)
        : const Color(0xFF9A7412);
    return Row(
      children: [
        Expanded(child: Divider(color: color.withValues(alpha: 0.45))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            '۞  $pageNumber  ۞',
            style: GoogleFonts.amiri(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(child: Divider(color: color.withValues(alpha: 0.45))),
      ],
    );
  }

  InlineSpan _ayahSpan(
    QuranAyah ayah,
    int index,
    Color normalTextColor,
    bool isDark,
  ) {
    final words = ayah.text.trim().split(RegExp(r'\s+'));
    return TextSpan(
      children: [
        for (final word in words)
          TextSpan(
            text: '$word ',
            style: TextStyle(
              color: _playing && index == _currentAyah
                  ? Color.lerp(normalTextColor, gold, 0.24)
                  : normalTextColor,
              backgroundColor: _playing && index == _currentAyah
                  ? gold.withValues(alpha: 0.10)
                  : null,
            ),
          ),
        TextSpan(
          text: '۝${ayah.number} ',
          style: TextStyle(
            color: _playing && index == _currentAyah
                ? gold
                : isDark
                ? gold.withValues(alpha: 0.9)
                : const Color(0xFF9A7412),
            fontSize: _fontSize * 0.72,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
