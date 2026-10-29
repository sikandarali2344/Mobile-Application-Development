import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../models/quran_models.dart';
import '../services/quran_service.dart';
import '../services/quran_storage.dart';
import '../widgets/animated_background.dart';
import 'bookmarks_screen.dart';
import 'settings_screen.dart';
import 'surah_detail_screen.dart';
import 'tasbeeh_screen.dart';

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

class _QuranHomeScreenState extends State<QuranHomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  final ScrollController _homeScrollController = ScrollController();
  List<QuranSurahSummary> _surahs = [];
  List<QuranSurahSummary> _bookmarkedSurahs = [];
  bool _loading = true;
  String _searchText = '';
  int _selectedIndex = 0;
  int? _selectedQuizAnswer;
  bool _quizSubmitted = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _homeScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final surahs = await QuranService.fetchSurahs();
      final bookmarks = await QuranStorage.getBookmarkedSurahIds();
      final bookmarkedSurahs = surahs
          .where((surah) => bookmarks.contains(surah.id))
          .toList();
      if (!mounted) return;
      setState(() {
        _surahs = surahs;
        _bookmarkedSurahs = bookmarkedSurahs;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _refreshBookmarks() async {
    final bookmarks = await QuranStorage.getBookmarkedSurahIds();
    final bookmarkedSurahs = _surahs
        .where((surah) => bookmarks.contains(surah.id))
        .toList();
    if (!mounted) return;
    setState(() => _bookmarkedSurahs = bookmarkedSurahs);
  }

  void _openSurah(QuranSurahSummary surah) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SurahDetailScreen(surah: surah)),
    ).then((_) => _refreshBookmarks());
  }

  @override
  Widget build(BuildContext context) {
    final filteredSurahs = _surahs.where((surah) {
      final query = _searchText.trim().toLowerCase();
      if (query.isEmpty) return true;
      return surah.name.toLowerCase().contains(query) ||
          surah.arabicName.contains(query) ||
          surah.translatedName.toLowerCase().contains(query);
    }).toList();

    final pages = [
      _buildHomePage(filteredSurahs),
      BookmarksScreen(
        bookmarkedSurahs: _bookmarkedSurahs,
        onOpenSurah: _openSurah,
      ),
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
    ];

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedBackground()),
          SafeArea(child: pages[_selectedIndex]),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) =>
              setState(() => _selectedIndex = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.bookmark_rounded),
              label: 'Bookmarks',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomePage(List<QuranSurahSummary> filteredSurahs) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth > 560
            ? 560.0
            : constraints.maxWidth;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  final progress = Curves.easeOutCubic.transform(
                    _animationController.value,
                  );
                  return Transform.translate(
                    offset: Offset(0, 18 * (1 - progress)),
                    child: Opacity(
                      opacity: progress,
                      child: ScrollConfiguration(
                        behavior: const MaterialScrollBehavior().copyWith(
                          dragDevices: {
                            PointerDeviceKind.touch,
                            PointerDeviceKind.mouse,
                            PointerDeviceKind.trackpad,
                          },
                        ),
                        child: Scrollbar(
                          controller: _homeScrollController,
                          thumbVisibility: true,
                          thickness: 8,
                          radius: const Radius.circular(20),
                          child: CustomScrollView(
                            controller: _homeScrollController,
                            physics: const BouncingScrollPhysics(),
                            slivers: [
                              const SliverToBoxAdapter(
                                child: SizedBox(height: 18),
                              ),
                              SliverToBoxAdapter(child: _buildHeader()),
                              const SliverToBoxAdapter(
                                child: SizedBox(height: 18),
                              ),
                              SliverToBoxAdapter(child: _buildHeroCard()),
                              const SliverToBoxAdapter(
                                child: SizedBox(height: 18),
                              ),
                              SliverToBoxAdapter(child: _buildSearchBox()),
                              const SliverToBoxAdapter(
                                child: SizedBox(height: 18),
                              ),
                              SliverToBoxAdapter(child: _buildPrayerCard()),
                              const SliverToBoxAdapter(
                                child: SizedBox(height: 18),
                              ),
                              SliverToBoxAdapter(child: _buildQuickStats()),
                              const SliverToBoxAdapter(
                                child: SizedBox(height: 18),
                              ),
                              SliverToBoxAdapter(child: _buildQuizCard()),
                              if (_loading)
                                const SliverFillRemaining(
                                  hasScrollBody: false,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              else if (filteredSurahs.isEmpty)
                                const SliverFillRemaining(
                                  hasScrollBody: false,
                                  child: Center(
                                    child: Text(
                                      'No surah found',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                SliverPadding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        child: _buildSurahCard(
                                          filteredSurahs[index],
                                          index,
                                        ),
                                      ),
                                      childCount: filteredSurahs.length,
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
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    final textPrimary = widget.darkMode
        ? Colors.white
        : const Color(0xFF102A22);
    final textSecondary = widget.darkMode
        ? const Color(0xFFEAF2FF)
        : const Color(0xFF4C6A5E);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quran',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Read, reflect, and renew your heart',
                style: TextStyle(color: textSecondary, fontSize: 14),
              ),
            ],
          ),
        ),
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.darkMode
                  ? [
                      const Color(0xFF38B2AC).withValues(alpha: 0.35),
                      const Color(0xFF7C3AED).withValues(alpha: 0.35),
                    ]
                  : [
                      const Color(0xFF0F766E).withValues(alpha: 0.18),
                      const Color(0xFFD9B36C).withValues(alpha: 0.22),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: (widget.darkMode ? Colors.white : Colors.black).withValues(
                alpha: 0.12,
              ),
            ),
          ),
          child: Icon(
            Icons.notifications_none_rounded,
            color: textPrimary,
            size: 28,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.94, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.darkMode
                ? [const Color(0xFF0A5C54), const Color(0xFF1D243A)]
                : [const Color(0xFF0F766E), const Color(0xFFD9B36C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: (widget.darkMode ? Colors.black : Colors.teal).withValues(
                alpha: 0.22,
              ),
              offset: const Offset(0, 18),
              blurRadius: 30,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.auto_stories_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Today’s reading',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Surah Al-Fatihah',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Open the path to light and reflection',
                    style: TextStyle(color: Color(0xFFEAF2FF), fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(
              widget.darkMode
                  ? Icons.dark_mode_rounded
                  : Icons.wb_sunny_rounded,
              color: Colors.white,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: widget.darkMode
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: (widget.darkMode ? Colors.white : Colors.black).withValues(
            alpha: 0.1,
          ),
        ),
      ),
      child: TextField(
        onChanged: (value) => setState(() => _searchText = value),
        style: TextStyle(
          color: widget.darkMode ? Colors.white : const Color(0xFF102A22),
        ),
        decoration: InputDecoration(
          hintText: 'Search Surah',
          hintStyle: TextStyle(
            color: widget.darkMode
                ? const Color(0xFFD8E3FF)
                : const Color(0xFF587267),
          ),
          border: InputBorder.none,
          icon: Icon(
            Icons.search_rounded,
            color: widget.darkMode ? Colors.white : const Color(0xFF0F766E),
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerCard() {
    final prayerTimes = [
      ('Fajr', '4:26 AM'),
      ('Dhuhr', '12:48 PM'),
      ('Asr', '5:05 PM'),
      ('Maghrib', '7:20 PM'),
      ('Isha', '8:42 PM'),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.darkMode
              ? [
                  const Color(0xFF102A2C).withValues(alpha: 0.88),
                  const Color(0xFF1E2A39).withValues(alpha: 0.96),
                ]
              : [const Color(0xFFEAF7F2), const Color(0xFFF5EEDB)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: (widget.darkMode ? Colors.white : Colors.black).withValues(
            alpha: 0.08,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: widget.darkMode
                      ? const Color(0xFF0F766E).withValues(alpha: 0.22)
                      : const Color(0xFF0F766E).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.access_time_rounded,
                  color: widget.darkMode
                      ? Colors.white
                      : const Color(0xFF0F766E),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Prayer times',
                style: TextStyle(
                  color: widget.darkMode
                      ? Colors.white
                      : const Color(0xFF102A22),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: prayerTimes.map((item) {
              final (label, time) = item;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: widget.darkMode
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.white.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: widget.darkMode
                            ? Colors.white70
                            : const Color(0xFF587267),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      time,
                      style: TextStyle(
                        color: widget.darkMode
                            ? Colors.white
                            : const Color(0xFF102A22),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard('Ayah', '114', Icons.auto_stories_rounded),
        ),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Juz', '30', Icons.book_rounded)),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Bookmarks',
            '${_bookmarkedSurahs.length}',
            Icons.bookmark_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildQuizCard() {
    final options = ['Al-Fatihah', 'Al-Mulk', 'Al-Alaq', 'An-Nas'];
    final correctAnswerIndex = 0;
    final isCorrect =
        _quizSubmitted && _selectedQuizAnswer == correctAnswerIndex;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.darkMode
              ? [
                  const Color(0xFF0A5C54).withValues(alpha: 0.75),
                  const Color(0xFF1D243A).withValues(alpha: 0.85),
                ]
              : [
                  const Color(0xFF0F766E).withValues(alpha: 0.96),
                  const Color(0xFFD9B36C).withValues(alpha: 0.92),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.quiz_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Daily Quran Quiz',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Which surah is known as the Opening Chapter?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          ...List.generate(options.length, (index) {
            final isSelected = _selectedQuizAnswer == index;
            final isAnswer = _quizSubmitted && index == correctAnswerIndex;
            final color = _quizSubmitted
                ? (isAnswer
                      ? Colors.green.shade400
                      : (isSelected
                            ? Colors.red.shade400
                            : Colors.white.withValues(alpha: 0.14)))
                : (isSelected
                      ? Colors.white.withValues(alpha: 0.28)
                      : Colors.white.withValues(alpha: 0.12));

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: _quizSubmitted
                    ? null
                    : () => setState(() => _selectedQuizAnswer = index),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${index + 1}.',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          options[index],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (_quizSubmitted && index == correctAnswerIndex)
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.white,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _selectedQuizAnswer == null
                      ? null
                      : () {
                          setState(() => _quizSubmitted = true);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0F766E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _quizSubmitted
                        ? (isCorrect ? 'Correct!' : 'Try again')
                        : 'Check answer',
                  ),
                ),
              ),
              if (_quizSubmitted) const SizedBox(width: 10),
              if (_quizSubmitted)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedQuizAnswer = null;
                      _quizSubmitted = false;
                    });
                  },
                  child: const Text(
                    'Reset',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
            ],
          ),
          if (_quizSubmitted)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                isCorrect
                    ? 'Correct answer! Al-Fatihah is the opening chapter.'
                    : 'Not quite — the correct answer is Al-Fatihah.',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    final bgStart = widget.darkMode
        ? Colors.white.withValues(alpha: 0.10)
        : Colors.white.withValues(alpha: 0.82);
    final bgEnd = widget.darkMode
        ? Colors.white.withValues(alpha: 0.05)
        : const Color(0xFFF0F5F3);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bgStart, bgEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: (widget.darkMode ? Colors.white : Colors.black).withValues(
            alpha: 0.08,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: widget.darkMode
                  ? const Color(0xFF0F766E).withValues(alpha: 0.32)
                  : const Color(0xFF0F766E).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: widget.darkMode ? Colors.white : const Color(0xFF0F766E),
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: widget.darkMode
                        ? Colors.white
                        : const Color(0xFF102A22),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: widget.darkMode
                        ? const Color(0xFFEAF2FF)
                        : const Color(0xFF587267),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahCard(QuranSurahSummary surah, int index) {
    final textPrimary = widget.darkMode
        ? Colors.white
        : const Color(0xFF102A22);
    final textSecondary = widget.darkMode
        ? const Color(0xFFEAF2FF)
        : const Color(0xFF587267);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.9, end: 1),
      duration: Duration(milliseconds: 280 + (index * 60)),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => _openSurah(surah),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.darkMode
                    ? [
                        Colors.white.withValues(alpha: 0.10),
                        Colors.white.withValues(alpha: 0.05),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.82),
                        const Color(0xFFF2F8F4),
                      ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: (widget.darkMode ? Colors.white : Colors.black)
                    .withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: widget.darkMode
                          ? [
                              const Color(0xFF7C87FF).withValues(alpha: 0.7),
                              const Color(0xFF0F766E).withValues(alpha: 0.9),
                            ]
                          : [const Color(0xFF0F766E), const Color(0xFFD9B36C)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      '${surah.id}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
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
                        surah.name,
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${surah.translatedName} • ${surah.versesCount} verses',
                        style: TextStyle(color: textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      surah.arabicName,
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      surah.revelationPlace,
                      style: TextStyle(color: textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
