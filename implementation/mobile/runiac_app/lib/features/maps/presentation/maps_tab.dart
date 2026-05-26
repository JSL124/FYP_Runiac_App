import 'package:flutter/material.dart';

import '../../../core/theme/runiac_colors.dart';
import 'widgets/maps_background.dart';
import 'widgets/maps_top_overlay.dart';
import 'widgets/shared_routes_sheet.dart';

class MapsTab extends StatelessWidget {
  const MapsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: RuniacColors.background,
      child: Stack(
        children: [
          Positioned.fill(child: MapsBackground()),
          Positioned(
            left: 14,
            right: 14,
            top: 0,
            child: SafeArea(
              minimum: EdgeInsets.only(top: 14),
              child: MapsTopOverlay(),
            ),
          ),
          SharedRoutesSheet(),
        ],
      ),
    );
  }
}
