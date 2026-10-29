# Noor Quran — setup and validation notes

## Included in this project
- Existing Flutter application screens, theme, bookmarks, login/sign-up flow, settings, and Tasbeeh screen are retained.
- Quran text is requested from the Quran.com API's Uthmani verse endpoint.
- Quran recitation uses one audio asset per ayah from the configured Mishary Alafasy collection. The playlist index is the single source of truth for highlighting the current ayah; the app no longer estimates ayah position by dividing total-surah duration.
- Urdu translation is resolved from the Quran.com translation-resource catalog and joined by `verse_key`. If the translation endpoint is unavailable, Arabic text remains available and the UI explains that translation is unavailable.
- Explore includes Karachi/Nawabshah prayer-time selection, six Hadith collection choices, daily duas, city-centre Qibla bearing calculation, and a digital Tasbeeh.
- Android internet permission and app label are set for Noor Quran.

## Run locally
1. Install Flutter and Android Studio (or VS Code with the Flutter extension).
2. Extract the ZIP and open `FlutterProjects/second_flutter_app` as the Flutter project root.
3. Run `flutter doctor` and resolve any local Android SDK issues.
4. Run `flutter pub get`.
5. Run `flutter analyze`.
6. Connect an Android device or start an emulator, then run `flutter run`.

## Accuracy, sources, and release checks
- Quran text source: https://api.quran.com/api/v4
- Recitation source configured in code: `https://everyayah.com/data/Alafasy_128kbps/`
- Prayer-time source: https://api.aladhan.com/ (method 1, Karachi calculation convention). Timings can differ from a local mosque's announced timetable; compare with a trusted local calendar before relying on them for prayer.
- Hadith preview service: https://api.hadith.gading.dev/ . The API provides a collection preview, not a scholarly verification workflow. Verify Arabic, grading, translation, and numbering against a trusted edition before publishing or sharing content.
- Qibla bearing is calculated from city-centre coordinates to the Kaaba. It is not a live compass and does not use the device magnetometer or GPS.
- Audio and translation need an internet connection. Offline content sync/download, scheduled/background Azan, live compass, and word-level Tajweed/audio timing are not implemented in this build.
- Do not advertise the project as fully validated until `flutter analyze`, device playback checks, verse/audio mapping checks across all 114 surahs, translation-resource checks, and local prayer-time comparisons have been completed on a real development setup.

## Manual release checklist
- [ ] Run `flutter analyze` and fix any errors/warnings that affect the build.
- [ ] Test all 114 surah audio playlists; confirm the verse number on screen follows the playlist index and no audio asset is missing.
- [ ] Compare sampled Arabic text and Urdu translations against the selected source editions.
- [ ] Compare today's Karachi prayer times with a trusted local mosque timetable.
- [ ] Verify each displayed dua's Arabic, meaning, and reference before public release.
- [ ] Test portrait layouts, font scaling, dark mode, bookmarks, and network-failure states on Android.
