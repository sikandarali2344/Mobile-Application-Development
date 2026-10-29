import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/quran_models.dart';
import '../theme/app_theme.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({
    super.key,
    required this.bookmarkedSurahs,
    required this.onOpenSurah,
  });

  final List<QuranSurahSummary> bookmarkedSurahs;
  final ValueChanged<QuranSurahSummary> onOpenSurah;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (bookmarkedSurahs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border_rounded,
              size: 80,
              color: isDark ? Colors.white38 : Colors.black26,
            ),
            const SizedBox(height: 12),
            Text(
              'No bookmarks yet',
              style: GoogleFonts.poppins(
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 60, 18, 120),
      itemCount: bookmarkedSurahs.length,
      itemBuilder: (_, i) {
        final s = bookmarkedSurahs[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => onOpenSurah(s),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.gold.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bookmark_rounded,
                        color: AppTheme.gold),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.name,
                            style: GoogleFonts.poppins(
                              color: isDark
                                  ? Colors.white
                                  : AppTheme.deepTeal,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            s.translatedName,
                            style: GoogleFonts.poppins(
                              color: isDark ? Colors.white60 : Colors.black54,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      s.arabicName,
                      style: GoogleFonts.amiri(
                        color: isDark ? Colors.white : AppTheme.deepTeal,
                        fontSize: 22,
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
}