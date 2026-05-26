import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';
import '../../../../core/widgets/card_title.dart';
import '../../../../core/widgets/dashboard_card.dart';
import 'home_placeholders.dart';

class GoalPreparationCard extends StatelessWidget {
  const GoalPreparationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardTitle(icon: Icons.flag_outlined, title: 'Training Goal'),
          SizedBox(height: 12),
          Text(
            'Your training preparation will appear here.',
            style: TextStyle(
              color: RuniacColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Next milestone appears after your plan starts.',
            style: TextStyle(
              color: RuniacColors.textSecondary,
              fontSize: 15,
              height: 1.4,
            ),
          ),
          SizedBox(height: 14),
          ProgressPlaceholder(),
        ],
      ),
    );
  }
}
