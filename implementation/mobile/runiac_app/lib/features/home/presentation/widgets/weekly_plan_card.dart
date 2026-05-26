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
          Row(
            children: [
              const Expanded(
                child: CardTitle(
                  icon: Icons.view_week_outlined,
                  title: 'This Week\'s Plan',
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: RuniacColors.primaryBlue,
                  side: const BorderSide(color: RuniacColors.border),
                  minimumSize: const Size(84, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text('View Plan'),
              ),
            ],
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
