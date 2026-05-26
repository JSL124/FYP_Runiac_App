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
  static const List<String> _messages = [
    'Home placeholder',
    'Plan placeholder',
    'Run placeholder',
    'Explore placeholder',
    'Leaderboard placeholder',
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Runiac'),
      ),
      body: Center(
        child: Text(_messages[_selectedIndex]),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note),
            label: 'Plan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_run),
            label: 'Run',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'Leaderboard',
          ),
        ],
      ),
    );
  }
}
