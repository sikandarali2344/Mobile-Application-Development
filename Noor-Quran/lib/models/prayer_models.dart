class PrayerSchedule {
  const PrayerSchedule({
    required this.fajr,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  final String fajr;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;

  Map<String, String> toMap() => {
        'Fajr': fajr,
        'Dhuhr': dhuhr,
        'Asr': asr,
        'Maghrib': maghrib,
        'Isha': isha,
      };

  factory PrayerSchedule.fromJson(Map<String, dynamic> json) {
    final timings = json['timings'] as Map<String, dynamic>? ?? const {};
    return PrayerSchedule(
      fajr: (timings['Fajr'] ?? '---') as String,
      dhuhr: (timings['Dhuhr'] ?? '---') as String,
      asr: (timings['Asr'] ?? '---') as String,
      maghrib: (timings['Maghrib'] ?? '---') as String,
      isha: (timings['Isha'] ?? '---') as String,
    );
  }
}
