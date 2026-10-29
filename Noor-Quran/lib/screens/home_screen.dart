import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/quran_models.dart';
import '../services/quran_service.dart';
import '../services/quran_storage.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_background.dart';
import 'bookmarks_screen.dart';
import 'settings_screen.dart';
import 'surah_detail_screen.dart';
import 'tasbeeh_screen.dart';
import 'islamic_features_screen.dart';

class QuranHomeScreen extends StatefulWidget {
  const QuranHomeScreen({
    super.key,
    required this.darkMode,
    required this.onThemeToggle,
  });

  final bool darkMode;
  final ValueChanged<bool> onThemeToggle;

  @override
  State<QuranHomeScreen> createState() => _QuranHomeScreenState();
}

class _QuranHomeScreenState extends State<QuranHomeScreen> {
  final ScrollController _scrollController = ScrollController();
  List<QuranSurahSummary> _surahs = [];
  List<QuranSurahSummary> _bookmarked = [];
  bool _loading = true;
  String _search = '';
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final surahs = await QuranService.fetchSurahs();
      final ids = await QuranStorage.getBookmarkedSurahIds();
      if (!mounted) return;
      setState(() {
        _surahs = surahs;
        _bookmarked = surahs.where((s) => ids.contains(s.id)).toList();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _refreshBookmarks() async {
    final ids = await QuranStorage.getBookmarkedSurahIds();
    if (!mounted) return;
    setState(() {
      _bookmarked = _surahs.where((s) => ids.contains(s.id)).toList();
    });
  }

  void _openSurah(QuranSurahSummary s) {
    QuranStorage.saveLastRead(s.id);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SurahDetailScreen(surah: s)),
    ).then((_) => _refreshBookmarks());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.darkMode;
    final filtered = _surahs.where((s) {
      final q = _search.trim().toLowerCase();
      if (q.isEmpty) return true;
      return s.name.toLowerCase().contains(q) ||
          s.arabicName.contains(q) ||
          s.translatedName.toLowerCase().contains(q);
    }).toList();

    final pages = [
      _buildHome(filtered, isDark),
      BookmarksScreen(bookmarkedSurahs: _bookmarked, onOpenSurah: _openSurah),
      SettingsScreen(
        darkMode: widget.darkMode,
        onDarkModeChanged: widget.onThemeToggle,
        prayerReminderEnabled: true,
        onPrayerReminderChanged: (_) {},
        onTasbeehTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TasbeehScreen()),
          );
        },
      ),
      const IslamicFeaturesScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedBackground()),
          SafeArea(child: pages[_tabIndex]),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: NavigationBar(
              selectedIndex: _tabIndex,
              height: 68,
              backgroundColor: isDark
                  ? Colors.black.withValues(alpha: 0.7)
                  : Colors.white.withValues(alpha: 0.9),
              indicatorColor: AppTheme.emerald.withValues(alpha: 0.25),
              onDestinationSelected: (i) => setState(() => _tabIndex = i),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.bookmark_rounded),
                  label: 'Saved',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_rounded),
                  label: 'Settings',
                ),
                NavigationDestination(
                  icon: Icon(Icons.mosque_rounded),
                  label: 'Explore',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHome(List<QuranSurahSummary> filtered, bool isDark) {
    return LayoutBuilder(
      builder: (context, c) {
        final maxW = c.maxWidth > 560 ? 560.0 : c.maxWidth;
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW),
            child: ScrollConfiguration(
              behavior: const MaterialScrollBehavior().copyWith(
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.trackpad,
                },
              ),
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                thickness: 6,
                radius: const Radius.circular(20),
                child: CustomScrollView(
                  controller: _scrollController,
                  primary: false,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    const SliverToBoxAdapter(child: SizedBox(height: 12)),
                    SliverToBoxAdapter(child: _header(isDark)),
                    const SliverToBoxAdapter(child: SizedBox(height: 18)),
                    SliverToBoxAdapter(child: _heroCard(isDark)),
                    const SliverToBoxAdapter(child: SizedBox(height: 18)),
                    SliverToBoxAdapter(child: _searchBox(isDark)),
                    const SliverToBoxAdapter(child: SizedBox(height: 18)),
                    SliverToBoxAdapter(child: _quickStats(isDark)),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'All Surahs',
                          style: GoogleFonts.poppins(
                            color: isDark ? Colors.white : AppTheme.deepTeal,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 12)),
                    if (_loading)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.gold,
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 100),
                        sliver: SliverList.builder(
                          itemCount: filtered.length,
                          itemBuilder: (_, i) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _surahCard(filtered[i], i, isDark),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _header(bool isDark) {
    final primary = isDark ? Colors.white : AppTheme.deepTeal;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'السلام عليكم',
                  style: GoogleFonts.amiri(
                    color: AppTheme.gold,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Noor Quran',
                  style: GoogleFonts.poppins(
                    color: primary,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.emerald, AppTheme.gold],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.mosque_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroCard(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0A4A47), Color(0xFF0F766E), Color(0xFFD4AF37)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppTheme.emerald.withValues(alpha: 0.4),
              blurRadius: 26,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.auto_stories_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today\'s Reading',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Surah Al-Fatihah',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَٰلَمِينَ',
                    style: GoogleFonts.amiri(
                      color: const Color(0xFFFAF6EC),
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.15);
  }

  Widget _searchBox(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.15)
                : AppTheme.emerald.withValues(alpha: 0.15),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: TextField(
          onChanged: (v) => setState(() => _search = v),
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.deepTeal,
          ),
          decoration: InputDecoration(
            hintText: 'Search Surah...',
            hintStyle: TextStyle(
              color: isDark ? Colors.white60 : Colors.black45,
            ),
            border: InputBorder.none,
            icon: Icon(
              Icons.search_rounded,
              color: isDark ? AppTheme.gold : AppTheme.emerald,
            ),
          ),
        ),
      ),
    );
  }

  Widget _quickStats(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: _stat('Surahs', '114', Icons.menu_book, isDark)),
          const SizedBox(width: 10),
          Expanded(child: _stat('Juz', '30', Icons.book, isDark)),
          const SizedBox(width: 10),
          Expanded(
            child: _stat(
              'Saved',
              '${_bookmarked.length}',
              Icons.bookmark,
              isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : AppTheme.emerald.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: isDark ? AppTheme.gold : AppTheme.emerald, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: isDark ? Colors.white : AppTheme.deepTeal,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: isDark ? Colors.white60 : Colors.black54,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _surahCard(QuranSurahSummary s, int i, bool isDark) {
    final primary = isDark ? Colors.white : AppTheme.deepTeal;
    final secondary = isDark ? Colors.white70 : Colors.black54;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => _openSurah(s),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : AppTheme.emerald.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.emerald, AppTheme.gold],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(
                    '${s.id}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.name,
                      style: GoogleFonts.poppins(
                        color: primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${s.translatedName} • ${s.versesCount} ayahs',
                      style: GoogleFonts.poppins(
                        color: secondary,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    s.arabicName,
                    style: GoogleFonts.amiri(
                      color: primary,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    s.revelationPlace,
                    style: GoogleFonts.poppins(
                      color: secondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(
          delay: Duration(milliseconds: 40 * (i % 10)),
          duration: 400.ms,
        ).slideX(begin: 0.1);
  }
}