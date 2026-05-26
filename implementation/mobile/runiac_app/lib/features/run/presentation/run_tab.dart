import 'package:flutter/material.dart';

import '../../../core/theme/runiac_colors.dart';
import 'widgets/run_controls.dart';
import 'widgets/run_map_placeholder.dart';
import 'widgets/run_plan_card.dart';

class RunTab extends StatelessWidget {
  const RunTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: ColoredBox(
        color: RuniacColors.background,
        child: Stack(
          children: [
            Positioned.fill(child: RunMapPlaceholder()),
            Positioned(left: 20, right: 20, bottom: 156, child: RunPlanCard()),
            Positioned(left: 20, right: 20, bottom: 18, child: RunControls()),
          ],
        ),
      ),
    );
  }
}
