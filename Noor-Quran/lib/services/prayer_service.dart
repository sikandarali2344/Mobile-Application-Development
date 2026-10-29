class QuranSurahSummary {
  final int id;
  final String name;
  final String arabicName;
  final String translatedName;
  final int versesCount;
  final String revelationPlace;

  QuranSurahSummary({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.translatedName,
    required this.versesCount,
    required this.revelationPlace,
  });

  factory QuranSurahSummary.fromJson(Map<String, dynamic> json) {
    return QuranSurahSummary(
      id: json['number'] ?? 0,
      name: json['englishName'] ?? '',
      arabicName: json['name'] ?? '',
      translatedName: json['englishNameTranslation'] ?? '',
      versesCount: json['numberOfAyahs'] ?? 0,
      revelationPlace: json['revelationType'] ?? '',
    );
  }
}

class QuranAyah {
  final int number;
  final String text;
  final String translation;

  QuranAyah({
    required this.number,
    required this.text,
    this.translation = '',
  });

  factory QuranAyah.fromJson(Map<String, dynamic> json) {
    return QuranAyah(
      number: json['numberInSurah'] ?? 0,
      text: json['text'] ?? '',
    );
  }
}