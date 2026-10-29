class QuranSurahSummary {
  const QuranSurahSummary({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.translatedName,
    required this.versesCount,
    required this.revelationPlace,
  });

  final int id;
  final String name;
  final String arabicName;
  final String translatedName;
  final int versesCount;
  final String revelationPlace;
}

class QuranAyah {
  const QuranAyah({
    required this.number,
    required this.text,
    this.translation = '',
  });

  final int number;
  final String text;
  final String translation;
}
