import 'package:flutter/material.dart';

void main() {
  runApp(const StepCircleApp());
}

class StepCircleApp extends StatelessWidget {
  const StepCircleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StepCircle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF2F4F3),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF18A69A),
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF111317),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF42CBB8),
          secondary: Color(0xFF42CBB8),
          surface: Color(0xFF1B1D22),
        ),
      ),
      themeMode: ThemeMode.dark,
      home: const StepCircleHome(),
    );
  }
}

class StepCircleHome extends StatefulWidget {
  const StepCircleHome({super.key});

  @override
  State<StepCircleHome> createState() => _StepCircleHomeState();
}

class _StepCircleHomeState extends State<StepCircleHome> {
  int _selectedIndex = 0;
  final int _steps = 0;
  int _dailyGoal = 10000;

  void _openGoals() {
    setState(() => _selectedIndex = 3);
  }

  void _setGoal(int goal) {
    setState(() {
      _dailyGoal = goal;
      _selectedIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      TodayPage(steps: _steps, goal: _dailyGoal, onSetGoal: _openGoals),
      const RankingPage(),
      const StatsPage(),
      GoalsPage(currentGoal: _dailyGoal, onGoalSelected: _setGoal),
      const ProfilePage(),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _selectedIndex, children: pages),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF171A1F),
          border: Border(top: BorderSide(color: Color(0xFF292C32))),
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            backgroundColor: const Color(0xFF171A1F),
            height: 68,
            indicatorColor: Colors.transparent,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined, color: Color(0xFF8D949F)),
                selectedIcon: Icon(Icons.home, color: Color(0xFF42CBB8)),
                label: 'Today',
              ),
              NavigationDestination(
                icon: Icon(Icons.bar_chart_outlined, color: Color(0xFF8D949F)),
                selectedIcon: Icon(Icons.bar_chart, color: Color(0xFF42CBB8)),
                label: 'Ranking',
              ),
              NavigationDestination(
                icon: Icon(Icons.show_chart, color: Color(0xFF8D949F)),
                selectedIcon: Icon(Icons.show_chart, color: Color(0xFF42CBB8)),
                label: 'Stats',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.emoji_events_outlined,
                  color: Color(0xFF8D949F),
                ),
                selectedIcon: Icon(
                  Icons.emoji_events,
                  color: Color(0xFF42CBB8),
                ),
                label: 'Goals',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline, color: Color(0xFF8D949F)),
                selectedIcon: Icon(Icons.person, color: Color(0xFF42CBB8)),
                label: 'You',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TodayPage extends StatelessWidget {
  const TodayPage({
    super.key,
    required this.steps,
    required this.goal,
    required this.onSetGoal,
  });

  final int steps;
  final int goal;
  final VoidCallback onSetGoal;

  @override
  Widget build(BuildContext context) {
    final progress = goal == 0 ? 0.0 : (steps / goal).clamp(0.0, 1.0);

    return Column(
      children: [
        const PageHeader(title: 'Today'),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ProgressCard(progress: progress, steps: steps, goal: goal),
                const SizedBox(height: 18),
                Text(
                  'This week',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                _WeekChart(progress: progress),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: onSetGoal,
                  icon: const Icon(Icons.flag_outlined, size: 18),
                  label: const Text('Set daily goal'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF42CBB8),
                    side: const BorderSide(color: Color(0xFF343941)),
                    minimumSize: const Size.fromHeight(46),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.title, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 10),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          action ??
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.refresh,
                  color: Colors.white70,
                  size: 20,
                ),
              ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.progress,
    required this.steps,
    required this.goal,
  });

  final double progress;
  final int steps;
  final int goal;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: const Color(0xFF191C21),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 150,
            height: 150,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 150,
                  height: 150,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 13,
                    backgroundColor: const Color(0xFF30343A),
                    color: const Color(0xFFE5EAF0),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$steps',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        height: 1,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'of $goal',
                      style: const TextStyle(
                        color: Color(0xFFAEB5BF),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            '${(goal * 0.0008).toStringAsFixed(1)} km',
            style: const TextStyle(color: Color(0xFF42CBB8), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _WeekChart extends StatelessWidget {
  const _WeekChart({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Container(
      height: 92,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      decoration: BoxDecoration(
        color: const Color(0xFF191C21),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(days.length, (index) {
          final heights = [18.0, 24.0, 16.0, 32.0, 21.0, 38.0, 28.0];
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 8,
                  height: heights[index] * (0.55 + progress * 0.45),
                  decoration: BoxDecoration(
                    color: index == 3
                        ? const Color(0xFF42CBB8)
                        : const Color(0xFF5A6069),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  days[index],
                  style: const TextStyle(
                    color: Color(0xFF9DA4AE),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class RankingPage extends StatelessWidget {
  const RankingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final users = [
      ('Aarav', '24,850', 1),
      ('Meera', '22,410', 2),
      ('Kabir', '19,320', 3),
      ('You', '0', 4),
    ];

    return Column(
      children: [
        const PageHeader(title: 'Ranking'),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            itemCount: users.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final user = users[index];
              final isYou = user.$1 == 'You';
              return Container(
                height: 72,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isYou
                      ? const Color(0xFF203934)
                      : const Color(0xFF191C21),
                  borderRadius: BorderRadius.circular(14),
                  border: isYou
                      ? Border.all(color: const Color(0xFF42CBB8), width: 0.8)
                      : null,
                ),
                child: Row(
                  children: [
                    _RankBadge(rank: user.$3),
                    const SizedBox(width: 12),
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFF30353B),
                      child: Text(
                        user.$1.substring(0, 1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        user.$1,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '${user.$2} steps',
                      style: const TextStyle(
                        color: Color(0xFF42CBB8),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank});
  final int rank;

  @override
  Widget build(BuildContext context) {
    final color = rank == 1
        ? const Color(0xFFFFC65A)
        : rank == 2
        ? const Color(0xFFC9D2DE)
        : rank == 3
        ? const Color(0xFFCD8D61)
        : const Color(0xFF69717B);
    return CircleAvatar(
      radius: 15,
      backgroundColor: color.withValues(alpha: 0.18),
      child: Text(
        '$rank',
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const PageHeader(title: 'Stats'),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _InfoCard(
                  children: const [
                    _StatRow(label: 'Total steps', value: '0'),
                    _StatRow(label: 'Average per recorded day', value: '0'),
                    _StatRow(label: 'Days recorded', value: '0'),
                    _StatRow(label: 'Best day', value: '0'),
                  ],
                ),
                const SizedBox(height: 14),
                _InfoCard(
                  title: 'Longest streak',
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        '0 days',
                        style: TextStyle(
                          color: Color(0xFF42CBB8),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _InfoCard(
                  title: 'Achievements',
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        'No achievements earned yet',
                        style: TextStyle(color: Color(0xFF9EA4AC)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class GoalsPage extends StatelessWidget {
  const GoalsPage({
    super.key,
    required this.currentGoal,
    required this.onGoalSelected,
  });

  final int currentGoal;
  final ValueChanged<int> onGoalSelected;

  @override
  Widget build(BuildContext context) {
    final goals = [5000, 8000, 10000, 12000, 15000];

    return Column(
      children: [
        const PageHeader(title: 'Goals'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            children: [
              _ProgressCard(
                progress: currentGoal == 0
                    ? 0
                    : (0 / currentGoal).clamp(0.0, 1.0),
                steps: 0,
                goal: currentGoal,
              ),
              const SizedBox(height: 16),
              const Text(
                'Daily goal',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              ...goals.map((goal) {
                final selected = goal == currentGoal;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () => onGoalSelected(goal),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      height: 58,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF203934)
                            : const Color(0xFF191C21),
                        borderRadius: BorderRadius.circular(14),
                        border: selected
                            ? Border.all(
                                color: const Color(0xFF42CBB8),
                                width: 0.8,
                              )
                            : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            selected
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: selected
                                ? const Color(0xFF42CBB8)
                                : const Color(0xFF69717B),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '$goal steps',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const PageHeader(title: 'You'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            children: [
              const CircleAvatar(
                radius: 44,
                backgroundColor: Color(0xFF30353B),
                child: Icon(Icons.person, size: 48, color: Colors.white70),
              ),
              const SizedBox(height: 12),
              const Text(
                'StepCircle Member',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 28),
              const _InfoCard(
                title: 'Progress',
                children: [
                  _StatRow(label: 'Today', value: '0 steps'),
                  _StatRow(label: 'This week', value: '0 steps'),
                  _StatRow(label: 'Recorded days', value: '0'),
                ],
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: null,
                icon: Icon(Icons.settings_outlined),
                label: Text('Settings'),
                style: ButtonStyle(
                  minimumSize: WidgetStatePropertyAll(Size.fromHeight(46)),
                  foregroundColor: WidgetStatePropertyAll(Color(0xFFB0B5BD)),
                  side: WidgetStatePropertyAll(
                    BorderSide(color: Color(0xFF343941)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({this.title, required this.children});

  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF191C21),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
          ],
          ...children,
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFFB2B7BE), fontSize: 13),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF42CBB8),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
