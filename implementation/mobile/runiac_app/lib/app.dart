import 'package:flutter/material.dart';

import 'core/theme/runiac_theme.dart';
import 'features/shell/runiac_shell.dart';

class RuniacApp extends StatelessWidget {
  const RuniacApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Runiac',
      theme: buildRuniacTheme(),
      home: const RuniacShell(),
    );
  }
}
