import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.darkMode,
    required this.onDarkModeChanged,
    required this.prayerReminderEnabled,
    required this.onPrayerReminderChanged,
    required this.onTasbeehTap,
  });

  final bool darkMode;
  final ValueChanged<bool> onDarkModeChanged;
  final bool prayerReminderEnabled;
  final ValueChanged<bool> onPrayerReminderChanged;
  final VoidCallback onTasbeehTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 18),
              _SettingTile(
                icon: Icons.dark_mode_rounded,
                title: 'Dark mode',
                subtitle: 'Switch between light and dark themes',
                trailing: Switch(value: darkMode, onChanged: onDarkModeChanged),
              ),
              const SizedBox(height: 12),
              _SettingTile(
                icon: Icons.access_time_rounded,
                title: 'Prayer reminders',
                subtitle: 'Get gentle reminders before each salah',
                trailing: Switch(
                  value: prayerReminderEnabled,
                  onChanged: onPrayerReminderChanged,
                ),
              ),
              const SizedBox(height: 12),
              _SettingTile(
                icon: Icons.auto_stories_rounded,
                title: 'Daily reading',
                subtitle: 'Continue with a few verses every day',
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              _SettingTile(
                icon: Icons.volume_up_rounded,
                title: 'Recitation',
                subtitle: 'Play Quran recitation with a tap',
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              _SettingTile(
                icon: Icons.emoji_events_rounded,
                title: 'Tasbeeh counter',
                subtitle: 'Track your daily dhikr and spiritual count',
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white,
                ),
                onTap: onTasbeehTap,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tile = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFFEAF2FF),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );

    if (onTap == null) {
      return tile;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: tile,
    );
  }
}
