# Noor Quran — Islamic features upgrade

## Included in this upgrade
- Traditional green, gold and warm-paper visual direction, using the existing app theme.
- Explore tab with prayer timings, Hadith collection selector, daily duas, Qibla direction guide and digital Tasbeeh.
- Prayer times fetched for Karachi or Nawabshah using AlAdhan's city timings API (internet required).
- Hadith preview fetched from an online Hadith API; verify references/translations with a trusted printed or scholarly edition before publishing.
- Surah recitation now uses separate ayah audio files from EveryAyah's Mishary Alafasy collection and follows the audio playlist's current index to highlight the ayah, instead of guessing ayah position from the whole-surah duration.

## Run
1. Install Flutter SDK compatible with the `environment.sdk` in `pubspec.yaml`.
2. Open `second_flutter_app` in VS Code or Android Studio.
3. Run `flutter pub get`.
4. Run `flutter run` on an Android device/emulator or supported desktop target.

## Accuracy and limitations
- Quran text continues to come from Quran.com API's Uthmani endpoint. Network access is required to fetch chapters and verses.
- Verse audio requires internet and the availability of each matching audio file. If a file is unavailable, the player reports an error rather than claiming successful playback.
- Prayer timings depend on the selected city and the API's calculation method; users should confirm local mosque adjustments.
- The Qibla card currently gives an approximate city-level direction and is **not** a live sensor compass. Device location and magnetometer integration are still needed for precise live bearing.
- The Hadith card fetches an online collection entry. This is a starter implementation, not a scholarly-verified complete offline Hadith library.
- Notifications, background Azan audio, true offline downloads, word-by-word Tajweed verification, and location/magnetometer-based Qibla are not claimed as complete in this upgrade.
