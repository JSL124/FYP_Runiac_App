import 'package:flutter/material.dart';

class RuniacColors {
  const RuniacColors._();

  static const primaryBlue = Color(0xFF2F50C7);
  static const accentOrange = Color(0xFFFC6818);
  static const white = Color(0xFFFFFFFF);
  static const background = Color(0xFFF7F8FC);
  static const textPrimary = Color(0xFF172033);
  static const textSecondary = Color(0xFF6B7280);
  static const border = Color(0xFFE6EAF2);
}

class RuniacApp extends StatelessWidget {
  const RuniacApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Runiac',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: RuniacColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: RuniacColors.white,
          foregroundColor: RuniacColors.textPrimary,
          elevation: 0,
          surfaceTintColor: RuniacColors.white,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: RuniacColors.white,
          selectedItemColor: RuniacColors.primaryBlue,
          unselectedItemColor: RuniacColors.textSecondary,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: RuniacColors.primaryBlue,
            foregroundColor: RuniacColors.white,
          ),
        ),
      ),
      home: const _RuniacShell(),
    );
  }
}

class _RuniacShell extends StatefulWidget {
  const _RuniacShell();

  @override
  State<_RuniacShell> createState() => _RuniacShellState();
}

class _RuniacShellState extends State<_RuniacShell> {
  static const List<Widget> _tabs = [
    _HomeTab(),
    _PlaceholderTab(
      title: 'Maps',
      message: 'Community routes and maps will appear here.',
    ),
    _PlaceholderTab(title: 'Run', message: 'Run tools will appear here.'),
    _PlaceholderTab(
      title: 'Leaderboard',
      message: 'Leaderboard content will appear here.',
    ),
    _PlaceholderTab(
      title: 'You',
      message: 'Profile and settings will appear here.',
    ),
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Runiac')),
      body: _tabs[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Maps'),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_run),
            label: 'Run',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'Leaderboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'You'),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ColoredBox(
        color: RuniacColors.background,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: RuniacColors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: RuniacColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _HomeAccentBar(),
                  const SizedBox(height: 18),
                  const Text(
                    'Ready for an easy run?',
                    style: TextStyle(
                      color: RuniacColors.textPrimary,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      height: 1.12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Keep today comfortable. Choose a route you know, ease into '
                    'the pace, and stop whenever your body asks for a break.',
                    style: TextStyle(
                      color: RuniacColors.textSecondary,
                      fontSize: 16,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.directions_run),
                      label: const Text('Start Run'),
                      style: FilledButton.styleFrom(
                        backgroundColor: RuniacColors.primaryBlue,
                        foregroundColor: RuniacColors.white,
                        minimumSize: const Size.fromHeight(52),
                        textStyle: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const _HomeGuidanceCard(),
            const SizedBox(height: 14),
            const _HomeEmptyStateCard(),
          ],
        ),
      ),
    );
  }
}

class _HomeAccentBar extends StatelessWidget {
  const _HomeAccentBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 5,
          decoration: BoxDecoration(
            color: RuniacColors.primaryBlue,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 18,
          height: 5,
          decoration: BoxDecoration(
            color: RuniacColors.accentOrange,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ],
    );
  }
}

class _HomeGuidanceCard extends StatelessWidget {
  const _HomeGuidanceCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: RuniacColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: RuniacColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Today\'s gentle focus',
              style: TextStyle(
                color: RuniacColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 14),
            _GuidanceRow(
              icon: Icons.self_improvement,
              text: 'Start easy and let the first stretch feel relaxed.',
            ),
            SizedBox(height: 12),
            _GuidanceRow(
              icon: Icons.favorite_border,
              text: 'Keep breathing comfortable instead of chasing speed.',
            ),
            SizedBox(height: 12),
            _GuidanceRow(
              icon: Icons.check_circle_outline,
              text: 'Finishing calmly still counts as a useful session.',
            ),
          ],
        ),
      ),
    );
  }
}

class _GuidanceRow extends StatelessWidget {
  const _GuidanceRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: RuniacColors.accentOrange),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: RuniacColors.textSecondary,
              fontSize: 15,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeEmptyStateCard extends StatelessWidget {
  const _HomeEmptyStateCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      elevation: 0,
      color: RuniacColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        side: BorderSide(color: RuniacColors.border),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your plan will appear here',
              style: TextStyle(
                color: RuniacColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'For now, use Start Run when you are ready for a simple, '
              'comfortable session.',
              style: TextStyle(
                color: RuniacColors.textSecondary,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
