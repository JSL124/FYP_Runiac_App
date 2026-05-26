import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';
import '../../../../core/widgets/card_title.dart';
import '../../../../core/widgets/dashboard_card.dart';
import '../../../../core/widgets/soft_notice.dart';

class RunPlanCard extends StatelessWidget {
  const RunPlanCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CardTitle(icon: Icons.event_available, title: 'Today\'s Plan'),
          SizedBox(height: 14),
          Text(
            'Ready for an easy run?',
            style: TextStyle(
              color: RuniacColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Route details will appear after setup.',
            style: TextStyle(
              color: RuniacColors.textSecondary,
              fontSize: 15,
              height: 1.4,
            ),
          ),
          SizedBox(height: 12),
          SoftNotice(text: 'Recommended effort will appear here.'),
        ],
      ),
    );
  }
}
