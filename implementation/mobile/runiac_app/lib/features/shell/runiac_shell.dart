import 'package:flutter/material.dart';

import '../home/presentation/home_tab.dart';
import '../leaderboard/presentation/leaderboard_tab.dart';
import '../maps/presentation/maps_tab.dart';
import '../run/presentation/run_tab.dart';
import '../you/presentation/you_tab.dart';

class RuniacShell extends StatefulWidget {
  const RuniacShell({super.key});

  @override
  State<RuniacShell> createState() => _RuniacShellState();
}

class _RuniacShellState extends State<RuniacShell> {
  static const List<Widget> _tabs = [
    HomeTab(),
    MapsTab(),
    RunTab(),
    LeaderboardTab(),
    YouTab(),
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0 || _selectedIndex == 1 || _selectedIndex == 2
          ? null
          : AppBar(title: const Text('Runiac')),
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
