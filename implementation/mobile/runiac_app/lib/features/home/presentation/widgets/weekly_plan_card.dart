import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';
import '../../../../core/widgets/card_title.dart';
import '../../../../core/widgets/dashboard_card.dart';
import 'home_placeholders.dart';

class WeeklyPlanCard extends StatelessWidget {
  const WeeklyPlanCard({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardTitle(
            icon: Icons.view_week_outlined,
            title: 'This Week\'s Plan',
          ),
          const SizedBox(height: 12),
          const Text(
            'Your weekly plan will appear after setup.',
            style: TextStyle(
              color: RuniacColors.textSecondary,
              fontSize: 14,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          const PlanSkeletonRow(),
          const SizedBox(height: 8),
          const PlanSkeletonRow(),
          const SizedBox(height: 8),
          const PlanSkeletonRow(),
        ],
      ),
    );
  }
}
