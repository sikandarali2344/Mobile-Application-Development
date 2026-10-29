# Noor Quran

> A thoughtfully designed Quran and Islamic companion app, built with Flutter.

Noor Quran brings Quran reading and recitation together with useful daily Islamic features in a calm, easy-to-use interface. Its emerald, teal, cream, and gold palette, Arabic typography, animated details, and dark theme give the app a distinctive look across supported platforms.

## Features

### 📖 Quran
- Browse all **114 surahs**, with Arabic and translated names, verse counts, and revelation places.
- Search surahs by English name, Arabic name, or translated name.
- Read Uthmani Arabic text alongside an optional Urdu translation.
- Move through the reader in pages, adjust Arabic text size, and follow the current ayah during recitation.
- Choose from four reciters: Mishary Rashid Alafasy, Abdul Basit, Hani ar-Rifai, and Maher al-Muaiqly.
- Save surahs to your bookmarks and find them later in the **Saved** section.

### 🕌 Daily Islamic features
- View the five daily prayer times for **Karachi** or **Nawabshah**, with a refresh option.
- Browse a preview and paginated entries from nine Hadith collections: Sahih al-Bukhari, Sahih Muslim, Sunan Abu Dawud, Jami at-Tirmidhi, Sunan an-Nasa'i, Sunan Ibn Majah, Muwatta Malik, Musnad Ahmad, and Sunan ad-Darimi.
- Read daily duas with their meanings and references.
- See an approximate Qibla bearing from the selected city's centre.
- Use the digital Tasbeeh, with 33, 99, and 100-count targets.

### ✨ Design and personalization
- Distinctive Islamic-inspired emerald, deep teal, warm cream, and gold colors.
- Light and dark themes; your theme choice is saved on your device.
- Custom Arabic and Latin typography, gradient cards, rounded surfaces, and subtle animations.
- Simple bottom navigation for **Home**, **Saved**, **Settings**, and **Explore**.
- Quran bookmarks and the full-screen Tasbeeh count are stored locally on the device.
- Responsive layouts and mouse/trackpad scrolling support, including for Flutter web.

## Screens at a glance

| Home | Quran reader | Explore |
| --- | --- | --- |
| Search and browse surahs, view reading highlights, and open saved surahs. | Read Arabic and Urdu, adjust text size, choose a reciter, and listen ayah by ayah. | Check prayer times, browse Hadith and duas, view the Qibla guide, and use Tasbeeh. |

## Run locally

### Requirements
- Flutter SDK compatible with the Dart constraint in [`pubspec.yaml`](./pubspec.yaml).
- An internet connection for Quran data, translations, prayer times, Hadith, and recitation audio.
- A supported device, emulator, desktop target, or a browser for web.

### Start the app

From the project directory:

```bash
flutter pub get
flutter run
```

To run in Chrome:

```bash
flutter run -d chrome
```

To check the project:

```bash
flutter analyze
```

## Data sources and important notes

- **Quran text and Urdu translations:** [Quran.com API](https://api.quran.com/api/v4)
- **Recitation audio:** [EveryAyah](https://everyayah.com/data/)
- **Prayer timings:** [AlAdhan API](https://api.aladhan.com/)
- **Hadith collection data:** [Hadith Gading API](https://api.hadith.gading.dev/)

Prayer times use the selected city's calculation convention and may differ from local mosque timetables. The Qibla guide is calculated from the city centre; it is **not** a live GPS or magnetic compass. Hadith and dua content is presented as an app feature, not as a scholarly verification service. Please check religious text, translations, numbering, and local prayer timings against trusted sources.

Quran text, translations, prayer times, Hadith data, and recitation audio require an internet connection. If a translation or audio file is unavailable, that content may not load. The app does not currently provide offline downloads, background Azan or scheduled prayer notifications, or a live sensor-based Qibla compass.

## Built with

- [Flutter](https://flutter.dev/) and Dart
- Material 3
- `google_fonts`, `flutter_animate`, and `just_audio`
- `http` for online data and `shared_preferences` for local settings and saved counts
