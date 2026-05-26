import 'package:flutter/material.dart';

class RuniacApp extends StatelessWidget {
  const RuniacApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Runiac',
      home: _RuniacShell(),
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
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Ready for an easy run?',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          const Text(
            'Keep it comfortable today. Start with a relaxed pace, take breaks '
            'when you need them, and focus on building the habit.',
            style: TextStyle(fontSize: 16, height: 1.4),
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: () {}, child: const Text('Start Run')),
          const SizedBox(height: 24),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Your plan will appear here',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
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
